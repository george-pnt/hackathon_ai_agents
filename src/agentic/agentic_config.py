from agenticos.connectors import BaseWorkflowConfig, CrewaiWorkflowConfig
from agenticos.node.models import AgenticConfig

workflows : dict[str,BaseWorkflowConfig] = {}

# Example workflow
# Import the Crew class. If you used the flow from CrewAI docs the following import should work
# If you are getting any erros please correct the import path
from kodo_template.crew import TemplatecrewCrew as Crew


workflows["DependencyAnalysisWorkflow"] = CrewaiWorkflowConfig(
    description="Analyzes dependency manager files to identify deprecated dependencies and security vulnerabilities.",
    inputs={
       "dependency_file_url": "The URL of the dependency manager file to analyze"
    },
    crew_cls=Crew,
)

config = AgenticConfig(name="DependencyAnalysisNode", workflows=workflows)
