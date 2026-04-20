import pandas as pd
import os

class DataLoader:

    def save_to_staging(self, data, filename):
        if not os.path.exists("staging"):
            os.makedirs("staging")

        df = pd.DataFrame(data)
        df.to_csv(f"staging/{filename}", index=False)