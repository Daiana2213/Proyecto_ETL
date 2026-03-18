import requests
from .base_extractor import BaseExtractor

class ApiExtractor(BaseExtractor):

    def __init__(self, url):
        self.url = url

    def extract(self):
        response = requests.get(self.url)
        return response.json()