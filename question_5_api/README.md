# Q5: Clinical Data API (FastAPI)

A RESTful API built with FastAPI that serves clinical trial adverse 
event data and calculates patient risk scores.

## How to Run

Install dependencies:
```
pip install fastapi uvicorn pandas
```

Start the server:
```
uvicorn main:app --reload
```
The API will be available at http://127.0.0.1:8000

Interactive documentation available at http://127.0.0.1:8000/docs

## Endpoints

```GET /```

Returns a welcome message confirming the API is running.

```POST /ae-query```

Dynamically filters the AE dataset by severity and/or treatment arm.
Both fields are optional — omitted fields return all records for that 
dimension.

```GET /subject-risk/{subject_id}```

Calculates a weighted safety risk score for a specific subject.
Severity weights: MILD = 1, MODERATE = 3, SEVERE = 5.
Risk categories: Low (<5), Medium (5-15), High (>=15).
Returns 404 if subject_id does not exist.

## Input Data
```adae.csv``` is exported from ```pharmaverseadam::adae``` using:
```
write.csv(pharmaverseadam::adae, "adae.csv", row.names = FALSE)
```