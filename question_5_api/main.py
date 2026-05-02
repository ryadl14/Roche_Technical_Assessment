from fastapi import FastAPI, HTTPException
import pandas as pd
from pydantic import BaseModel
from typing import Optional, List

# In R, this code was ran to import the data:
# write.csv(pharmaverseadam::adae, "../question_5_api/adae.csv", row.names = FALSE)

app = FastAPI()
adae = pd.read_csv("adae.csv") # Loads the adae data.

# =================

@app.get("/")
def root():
    return {"message": "Clinical Trial Data API is running."}

class AEQuery(BaseModel):
    severity: Optional[List[str]] = None  # Accepts an optional list of severities
    treatment_arm: Optional[str] = None   # Accepts an specific treatment arm (optional)

# =================

@app.post("/ae-query")
def dynamic_filtering(query: AEQuery):
    df = adae.copy() # Create a working copy so filters don't modify original data.

    if query.severity is not None: # Checks if user provided a severity, if not, skips this filter
        df = df[df["AESEV"].isin(query.severity)] # Only retains the rows where AESEV matches the user severity input.

    if query.treatment_arm is not None:
        df = df[df["ACTARM"] == query.treatment_arm] # Only retains the rows where ACTARM matches the user treatment arm input.
 
    return { # In dictionary form so FastAPI can serialise it to JSON.
        "count": len(df), # Number of matching records after filtering
        "subjects": df["USUBJID"].unique().tolist() # Returns a list of the unique subject IDs
        }

# =================

@app.get("/subject-risk/{subject_id}")
def calculation_logic(subject_id:str): 
    if subject_id not in adae['USUBJID'].unique(): # Checks if the inputted subject_id exists, throws a 404 error if not.
        raise HTTPException(status_code=404, detail= "Subject not found.")
    else:
        filtered_df = adae[adae["USUBJID"] == subject_id] # Creates a filtered dataframe with the relevant rows for the subject.
        weighted_score = { # Creates the weighted score in a dictionary.
            "MILD" : 1,
            "MODERATE" : 3,
            "SEVERE" : 5
        }

        risk_score = filtered_df["AESEV"].map(weighted_score).sum() # Maps the AESEV scores to the weighted_score dictionary, then adds them all together.
        
        if risk_score < 5:          # Sorts the risk_score into categories.
            risk_category = "Low"
        elif 5 <= risk_score < 15:
            risk_category = "Medium"
        else:
            risk_category = "High"

        return { # Returns the subject_id, risk_score and risk_category.
            "subject_id" : subject_id,
            "risk_score" : int(risk_score), # Got a ValueError: [TypeError("'numpy.int64' object is not iterable") without the int before.
            "risk_category" : risk_category
        }

