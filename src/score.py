import json
import joblib
import pandas as pd

# Variável global para armazenar o modelo
model = None


def init():

    global model
    
    model_path = "model.pkl"
    model = joblib.load(model_path)



def run(raw_data):
    
    try:
        data = json.loads(raw_data)

        df = pd.DataFrame(data)

        predictions = model.predict(df)

        return json.dumps(predictions.tolist())
    
    except Exception as e:
        error = str(e)
        return json.dumps({"erro": error})
