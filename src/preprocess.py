import pandas as pd
from sklearn.model_selection import train_test_split

def load_data(data_path) -> pd.DataFrame:
    return pd.read_csv(data_path)

def preprocess(df: pd.DataFrame):
    X = df.drop(columns=["Result"])
    y = df["Result"]

    return train_test_split(
        X, y,
        test_size=0.2,
        random_state=42,
        stratify=y
    )
