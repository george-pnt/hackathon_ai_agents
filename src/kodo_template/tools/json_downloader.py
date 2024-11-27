from typing import Any, Optional, Type
import requests
import json
from pydantic import BaseModel, Field

from crewai.tools import BaseTool  # Adjust the import based on your project structure


class JSONDownloaderToolSchema(BaseModel):
    """Input schema for JSONDownloader."""
    website_url: str = Field(..., description="The URL of the website to download JSON data from")


class DependencyFileDownloader(BaseTool):
    name: str = "DependencyFileDownloader"
    description: str = "Downloads dependency manager files from a specified URL."

    args_schema: Type[BaseModel] = JSONDownloaderToolSchema

    def _run(self, website_url: str, **kwargs: Any) -> Any:
        headers = {
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0"
        }

        try:
            response = requests.get(website_url, headers=headers, timeout=15)
            response.raise_for_status()
            data = response.json()  # Parse response content as JSON
            return data  # Return the parsed JSON data
        except requests.RequestException as e:
            return {"error": f"An error occurred while requesting the URL: {e}"}
        except json.JSONDecodeError as e:
            return {"error": f"Failed to parse JSON: {e}"}