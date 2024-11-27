from agenticos.connectors import BaseWorkflowConfig, CrewaiWorkflowConfig
from agenticos.node.models import AgenticConfig

workflows : dict[str,BaseWorkflowConfig] = {}

# Example workflow
# Import the Crew class. If you used the flow from CrewAI docs the following import should work
# If you are getting any erros please correct the import path
from kodo_template.crew import TemplatecrewCrew as Crew


workflows["JSONDataAnalysisWorkflow"] = CrewaiWorkflowConfig(
    description="Downloads and analyzes JSON data from a specified website URL.",
    inputs={
        "website_url": "The URL of the website to download JSON data from"
    },
    crew_cls=Crew,
)

config = AgenticConfig(name="JSONDataAnalysisNode", workflows=workflows)
