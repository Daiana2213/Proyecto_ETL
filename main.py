from extractors.csv_extractor import CsvExtractor
from extractors.db_extractor import DatabaseExtractor
from extractors.api_extractor import ApiExtractor
from loaders.data_loader import DataLoader
from utils.logger import log_info
import json

def main():

    loader = DataLoader()

    #Aqui los CSV
    csv_files = [
        "data/customers.csv",
        "data/orders.csv",
        "data/order_details.csv",
        "data/products.csv"
    ]

    for file in csv_files:
        extractor = CsvExtractor(file)
        data = extractor.extract()

        filename = file.split("/")[-1]
        loader.save_to_staging(data, f"staging_{filename}")
        log_info(f"{filename} procesado correctamente")

    #Mi BD llamada VentasDW
    with open("config/config.json") as f:
        config = json.load(f)

    query = """
    SELECT 
    c.NombreCliente,
    p.NombreProducto,
    h.CantidadVendida,
    h.TotalVenta
    FROM HechoVentas h
    JOIN DimCliente c ON h.IdCliente = c.IdCliente
    JOIN DimProducto p ON h.IdProducto = p.IdProducto;
    """

    db_extractor = DatabaseExtractor(config["connection_string"], query)
    db_data = db_extractor.extract()

    loader.save_to_staging(db_data, "db_data.csv")
    log_info("Datos de BD procesados")

    #La API
    api_extractor = ApiExtractor("https://jsonplaceholder.typicode.com/comments")
    api_data = api_extractor.extract()

    loader.save_to_staging(api_data, "api_data.csv")
    log_info("Datos de API procesados")

if __name__ == "__main__":
    main()