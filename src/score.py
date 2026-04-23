import json
import os
import pandas as pd
import mlflow.pyfunc

model = None


def init():

    global model
    
    model_path = os.path.join(os.environ.get("AZUREML_MODEL_DIR"), "model")
    model = mlflow.pyfunc.load_model(model_path)

def run(raw_data):
    
    try:
        data = json.loads(raw_data)

        df = pd.DataFrame(data)

        predictions = model.predict(df)

        return json.dumps(predictions.tolist())
    
    except Exception as e:
        error = str(e)
        return json.dumps({"erro": error})
