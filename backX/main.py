from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
import joblib
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
import uvicorn
import logging

# Configuration du logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Job Recommender API",
    description="API de recommandation d'emploi basée sur IA",
    version="1.0.0"
)

# Modèles Pydantic pour les requêtes
class UserProfile(BaseModel):
    user_id: str
    skills: List[str] = Field(..., description="Liste des compétences de l'utilisateur")
    location: str = Field(..., description="Localisation de l'utilisateur")
    experience: int = Field(..., description="Niveau d'expérience")
    preferred_titles: Optional[List[str]] = Field(default=[], description="Titres de poste préférés")

class JobData(BaseModel):
    job_id: str
    title: str
    company: str
    location: str
    description: str
    skills: Optional[List[str]] = Field(default=[], description="Compétences requises pour le poste")
    work_type: Optional[str] = "Unknown"
    employment_type: Optional[str] = "Unknown"

class RecommendationRequest(BaseModel):
    user_profile: UserProfile
    jobs: List[JobData]
    top_k: Optional[int] = Field(default=10, description="Nombre de recommandations à retourner")
    threshold: Optional[float] = Field(default=0.3, description="Seuil de probabilité minimum")

class RecommendationResponse(BaseModel):
    job_id: str
    title: str
    company: str
    location: str
    probability: float
    confidence: str
    match_reasons: List[str]

# Variables globales pour le modèle
model = None
jobs_df = None

@app.on_event("startup")
async def load_model():
    """Charge le modèle au démarrage de l'application"""
    global model, jobs_df
    
    try:
        # Charger le modèle entraîné
        model = joblib.load('job_recommender_model.pkl')
        logger.info("Modèle chargé avec succès")
        
        # Charger le dataset des jobs (optionnel, pour les métadonnées)
        try:
            jobs_df = pd.read_csv('clean_jobs.csv')
            logger.info(f"Dataset des jobs chargé : {len(jobs_df)} emplois")
        except FileNotFoundError:
            logger.warning("Dataset des jobs non trouvé, fonctionnement en mode API uniquement")
            jobs_df = None
            
    except FileNotFoundError:
        logger.error("Modèle non trouvé ! Veuillez d'abord entraîner le modèle.")
        raise

def calculate_skill_match(user_skills: List[str], job_description: str, job_skills: Optional[List[str]] = None):
    """Calcule un score de similarité entre les compétences de l'utilisateur et une offre (description + skills)"""
    if not user_skills:
        return 0.0, []

    # 1. Rendre tout en minuscules pour la comparaison
    user_skills_set = set(skill.lower() for skill in user_skills)
    
    # 2. Traiter la description (comme avant)
    desc_lower = job_description.lower() if job_description else ""
    
    matched_skills = set()
    
    for skill in user_skills_set:
        if skill in desc_lower:
            matched_skills.add(skill)

    # 3. Ajouter la correspondance avec job.skills (liste)
    if job_skills:
        job_skills_set = set(s.lower() for s in job_skills)
        intersection = user_skills_set.intersection(job_skills_set)
        matched_skills.update(intersection)
    
    # 4. Score final basé sur le nombre de compétences matches
    score = len(matched_skills) / len(user_skills_set) if user_skills_set else 0.0
    return score, list(matched_skills)


def calculate_location_match(user_location, job_location):
    """Calcule le score de correspondance géographique"""
    if not job_location or not user_location:
        return 0.3
    
    user_city = user_location.split(',')[0].strip()
    job_city = job_location.split(',')[0].strip()
    
    if user_city.lower() == job_city.lower():
        return 1.0
    
    # États similaires
    user_parts = user_location.split(',')
    job_parts = job_location.split(',')
    
    if len(user_parts) > 1 and len(job_parts) > 1:
        user_state = user_parts[1].strip()
        job_state = job_parts[1].strip()
        if user_state.lower() == job_state.lower():
            return 0.6
    if any(keyword in job_location.lower() for keyword in ['remote', 'télétravail', 'distance']):
        return 0.8
    
    return 0.2

def calculate_title_match(preferred_titles, job_title):
    """Calcule le score de correspondance du titre"""
    if not job_title or not preferred_titles:
        return 0.1
    
    job_title_lower = job_title.lower()
    
    for pref_title in preferred_titles:
        if pref_title.lower() in job_title_lower:
            return 1.0
    
    # Correspondance partielle
    title_words = job_title_lower.split()
    max_score = 0.0
    
    for pref_title in preferred_titles:
        pref_words = set(pref_title.lower().split())
        common_words = set(title_words).intersection(pref_words)
        if common_words:
            score = len(common_words) / len(pref_words)
            max_score = max(max_score, score * 0.7)
    
    return max(max_score, 0.1)

def generate_match_reasons(skill_score, matched_skills, location_score, title_score, user_profile, job):
    """Génère les raisons de correspondance"""
    reasons = []
    
    if skill_score > 0.3 and matched_skills:
        if len(matched_skills) == 1:
            reasons.append(f"Compétence correspondante : {matched_skills[0]}")
        else:
            reasons.append(f"Compétences correspondantes : {', '.join(matched_skills[:3])}")
    
    
    if location_score > 0.8:
        reasons.append("Localisation parfaite")
    elif location_score > 0.5:
        reasons.append("Localisation dans la même région")
    
    if title_score > 0.8:
        reasons.append("Titre de poste très pertinent")
    elif title_score > 0.5:
        reasons.append("Titre de poste partiellement pertinent")
    
    if user_profile.experience >= 3:
        reasons.append("Profil expérimenté recherché")
    
    if len(reasons) == 0:
        reasons.append("Correspondance basée sur l'analyse globale du profil")
    
    return reasons

def create_fallback_recommendation(job, user_profile, skill_score, matched_skills, location_score, title_score):
    """Crée une recommandation de base quand le modèle ML n'est pas disponible"""
    # Score composite simple
    composite_score = (skill_score * 0.4 + location_score * 0.3 + title_score * 0.3)
    
    # Ajustement basé sur l'expérience
    if user_profile.experience >= 5:
        composite_score *= 1.1
    elif user_profile.experience >= 2:
        composite_score *= 1.05
    
    # Normaliser le score
    probability = min(composite_score, 1.0)
    
    # Déterminer le niveau de confiance
    if probability >= 0.7:
        confidence = "Élevée"
    elif probability >= 0.5:
        confidence = "Moyenne"
    else:
        confidence = "Faible"
    
    return probability, confidence


@app.post("/recommend", response_model=List[RecommendationResponse])
async def recommend_jobs(request: RecommendationRequest):
    """Endpoint principal pour obtenir des recommandations"""
    
    try:
        user_profile = request.user_profile
        jobs = request.jobs
        
        logger.info(f"Traitement de {len(jobs)} emplois pour l'utilisateur {user_profile.user_id}")
        logger.info(f"Compétences utilisateur: {user_profile.skills}")
        logger.info(f"Titres préférés: {user_profile.preferred_titles}")
        
        all_recommendations = []
        
        # Préparer les données pour chaque job
        for job in jobs:
            try:
                # Calculer les scores individuels
                skill_score, matched_skills = calculate_skill_match(user_profile.skills, job.description, getattr(job, "skills", None))
                location_score = calculate_location_match(user_profile.location, job.location)
                title_score = calculate_title_match(user_profile.preferred_titles, job.title)
                
                logger.info(f"Job {job.job_id} - Skill: {skill_score:.2f}, Location: {location_score:.2f}, Title: {title_score:.2f}")
                
                # Utiliser le modèle ML si disponible
                if model is not None:
                    try:
                        # Préparer les features pour le modèle
                        user_skills_str = ', '.join(user_profile.skills)
                        job_skills_str = ' '.join(job.skills) if job.skills else ''
                        weighted_skills = (job_skills_str + ' ') * 3
                        weighted_description = (job.description + ' ') * 1
                        combined_text = f"{user_skills_str} {job.title} {weighted_skills} {weighted_description}"
                        
                        # Créer un DataFrame pour la prédiction
                        job_data = pd.DataFrame({
                            'combined_text': [combined_text],
                            'skill_score': [skill_score],
                            'location_score': [location_score],
                            'title_score': [title_score],
                            'user_experience': [user_profile.experience],
                            'work_type': [job.work_type],
                            'employment_type': [job.employment_type]
                        })
                        
                        # Prédiction
                        probability = model.predict_proba(job_data)[0][1]
                        
                        # Déterminer le niveau de confiance
                        if probability >= 0.8:
                            confidence = "Très élevée"
                        elif probability >= 0.6:
                            confidence = "Élevée"
                        elif probability >= 0.4:
                            confidence = "Moyenne"
                        else:
                            confidence = "Faible"
                            
                    except Exception as e:
                        logger.warning(f"Erreur avec le modèle ML pour le job {job.job_id}: {e}")
                        probability, confidence = create_fallback_recommendation(
                            job, user_profile, skill_score, matched_skills, location_score, title_score
                        )
                else:
                    # Utiliser le système de fallback
                    probability, confidence = create_fallback_recommendation(
                        job, user_profile, skill_score, matched_skills, location_score, title_score
                    )
                
                logger.info(f"Job {job.job_id} - Probability: {probability:.3f}, Confidence: {confidence}")
                
                # Filtrer selon le seuil
                #if probability >= request.threshold:
                    # Générer les raisons de correspondance
                match_reasons = generate_match_reasons(
                        skill_score, matched_skills, location_score, title_score, 
                        user_profile, job
                )
                    
                all_recommendations.append((probability, RecommendationResponse(
                        job_id=job.job_id,
                        title=job.title,
                        company=job.company,
                        location=job.location,
                        probability=round(probability, 4),
                        confidence=confidence,
                        match_reasons=match_reasons
                        )
                ))
                    
            except Exception as e:
                logger.error(f"Erreur lors du traitement du job {job.job_id}: {e}")
                continue
        
        # Trier par probabilité décroissante et limiter au top_k
        # Trier tous les jobs par probabilité décroissante
        all_recommendations.sort(key=lambda x: x[0], reverse=True)

        # Extraire ceux qui dépassent le seuil
        recommendations = [rec for prob, rec in all_recommendations if prob >= request.threshold]

        # Si rien au-dessus du seuil, retourner quand même les top_k meilleurs
        if not recommendations:
            recommendations = [rec for _, rec in all_recommendations[:request.top_k]]

        logger.info(f"Recommandations générées pour {user_profile.user_id}: {len(recommendations)} emplois")
        
        return recommendations
        
    except Exception as e:
        logger.error(f"Erreur lors de la recommandation: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Erreur interne: {str(e)}")       
        
    

@app.post("/recommend_single")
async def recommend_single_job(user_profile: UserProfile, job: JobData):
    """Endpoint pour évaluer un seul job"""
    
    if model is None:
        raise HTTPException(status_code=500, detail="Modèle non chargé")
    
    try:
        # Calculer les scores
        skill_score, matched_skills = calculate_skill_match(user_profile.skills, job.description)
        location_score = calculate_location_match(user_profile.location, job.location)
        title_score = calculate_title_match(user_profile.preferred_titles, job.title)
        
        # Préparer les features
        user_skills_str = ', '.join(user_profile.skills)
        combined_text = f"{user_skills_str} {job.title} {job.description}"
        
        job_data = pd.DataFrame({
            'combined_text': [combined_text],
            'skill_score': [skill_score],
            'location_score': [location_score],
            'title_score': [title_score],
            'user_experience': [user_profile.experience],
            'work_type': [job.work_type],
            'employment_type': [job.employment_type]
        })
        
        # Prédiction
        probability = model.predict_proba(job_data)[0][1]
        prediction = model.predict(job_data)[0]
        
        return {
            "job_id": job.job_id,
            "title": job.title,
            "company": job.company,
            "probability": round(probability, 4),
            "recommended": bool(prediction),
            "skill_score": round(skill_score, 4),
            "location_score": round(location_score, 4),
            "title_score": round(title_score, 4),
            "matched_skills": matched_skills
        }
        
    except Exception as e:
        logger.error(f"Erreur lors de l'évaluation: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Erreur interne: {str(e)}")

@app.get("/model_info")
async def get_model_info():
    """Informations sur le modèle chargé"""
    
    if model is None:
        raise HTTPException(status_code=500, detail="Modèle non chargé")
    
    # Informations sur le modèle
    model_info = {
        "model_type": str(type(model.named_steps['classifier'])),
        "preprocessor_steps": list(model.named_steps['preprocessor'].named_transformers_.keys()),
        "feature_count": model.named_steps['preprocessor'].transform(
            pd.DataFrame({
                'combined_text': ['test'],
                'skill_score': [0.5],
                'location_score': [0.5],
                'title_score': [0.5],
                'user_experience': [3],
                'work_type': ['Unknown'],
                'employment_type': ['Unknown']
            })
        ).shape[1] if model else 0,
        "jobs_dataset_loaded": jobs_df is not None,
        "jobs_count": len(jobs_df) if jobs_df is not None else 0
    }
    
    return model_info

@app.get("/health")
async def health_check():
    """Vérification de l'état de l'API"""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "timestamp": pd.Timestamp.now().isoformat()
    }

@app.get("/")
async def root():
    """Page d'accueil de l'API"""
    return {
        "message": "Job Recommender API",
        "version": "1.0.0",
        "endpoints": {
            "recommend": "POST /recommend - Recommandations multiples",
            "recommend_single": "POST /recommend_single - Évaluation d'un job",
            "model_info": "GET /model_info - Informations sur le modèle",
            "health": "GET /health - État de l'API"
        }
    }

# Exemple d'utilisation pour tester l'API
example_request = {
    "user_profile": {
        "user_id": "user123",
        "skills": ["Python", "Machine Learning", "SQL"],
        "location": "New York, NY",
        "experience": 3,
        "preferred_titles": ["Data Scientist", "ML Engineer"]
    },
    "jobs": [
        {
            "job_id": "job1",
            "title": "Data Scientist",
            "company": "Tech Corp",
            "location": "New York, NY",
            "description": "Looking for a data scientist with Python and ML experience",
            "work_type": "Full-time",
            "employment_type": "Permanent"
        },
        {
            "job_id": "job2",
            "title": "Frontend Developer",
            "company": "Web Co",
            "location": "San Francisco, CA",
            "description": "React and JavaScript developer needed",
            "work_type": "Full-time",
            "employment_type": "Contract"
        }
    ],
    "top_k": 5,
    "threshold": 0.3
}

if __name__ == "__main__":
    print("Exemple de requête pour tester l'API:")
    print("POST /recommend")
    print(example_request)
    print("\nPour lancer l'API:")
    print("uvicorn main:app --reload --host 0.0.0.0 --port 8000")
    
    # Lancer l'API
    uvicorn.run(app, host="0.0.0.0", port=8000)







'''from fastapi import FastAPI, Request
from pydantic import BaseModel
from typing import List, Dict
from joblib import load
from recommendation_system import MobileRecommendationAPI  # ton code ci-dessus
import uvicorn

app = FastAPI()
api = MobileRecommendationAPI()

class UserProfile(BaseModel):
    id: str
    skills: List[str]
    experience: float
    location: str
    salary_expectation: float
    accepts_remote: bool

class JobOffer(BaseModel):
    id: str
    title: str
    company: str
    location: str
    date_posted: str
    skills_required: List[str]
    experience_required: float
    salary: float
    remote: bool
    description: str

class RecommendationRequest(BaseModel):
    user: UserProfile
    jobs: List[JobOffer]

@app.post("/recommend")
async def recommend(data: RecommendationRequest):
    result = api.get_recommendations_for_user(data.user.dict(), [job.dict() for job in data.jobs])
    return result

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
'''
