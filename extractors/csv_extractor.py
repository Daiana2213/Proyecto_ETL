import pandas as pd
from .base_extractor import BaseExtractor

class CsvExtractor(BaseExtractor):

    def __init__(self, file_path):
        self.file_path = file_path

    def extract(self):
        data = pd.read_csv(self.file_path)
        return data