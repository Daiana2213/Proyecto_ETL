import pyodbc
from .base_extractor import BaseExtractor

class DatabaseExtractor(BaseExtractor):

    def __init__(self, connection_string, query):
        self.connection_string = connection_string
        self.query = query

    def extract(self):
        conn = pyodbc.connect(self.connection_string)
        cursor = conn.cursor()
        cursor.execute(self.query)

        columns = [column[0] for column in cursor.description]
        data = []

        for row in cursor.fetchall():
            data.append(dict(zip(columns, row)))

        conn.close()
        return data