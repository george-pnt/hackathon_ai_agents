# Kodosumi Template Workflow

This template is designed to help you set up a node for a multi-agent distributed AI system with ease, leveraging the powerful and flexible framework provided by crewAI, augemented by Agentic AI package: kodosumi. Our goal is to enable your agents to collaborate effectively on complex tasks, maximizing their collective intelligence and capabilities.  

> The final goal of the project is to create a multi-agent network of reusable agents, powered by **kodosumi**, available through agentic store **sokosumi** and interconnected through registry layer **masumi**. Read more about the project [here](https://masumi.network).

## Installation

### Requirements 

> Install the following dependencies:

- Python >=3.10 <=3.13
- CrewAI
- FastAPI
- Uvicorn
- [uv](https://docs.astral.sh/uv/)
- gcc
- python3-dev
- build-essential
- (optional) Docker Desktop

> If you decide to go with Docker, you don't need to install dependencies, except Docker Desktop.

### Setup Instructions

1. **Install `uv`:**

   ```bash
   pip install uv
   ```

2. **Install `pipx` and `crewai`:**

   ```bash
   python3 -m pip install --user pipx
   python3 -m pipx ensurepath
   pipx install crewai
   ```

3. **Clone the Repository:**

   ```bash
   git clone https://github.com/pa1ar/kodo-template.git
   cd kodo-template
   ```

4. **Install Dependencies:**

   ```bash
   crewai install
   pip install -e .
   ```

5. **Set Up Environment Variables:**

   Rename `.env.example` to `.env` and fill in the missing values. Most importantly, you need to add your OpenAI API key.

   ```plaintext
   OPENAI_API_KEY=your_openai_api_key
   ```

6. **Change the name of the node:**

   Modify name of the node in `src/agentic/agentic_config.py`, line 23 (by default it is `TEMPLATE_NODE`, but you can change it to anything you want - it makes the node more recognizable for you on the registry).

## Running the Project

First, you need to ensure that crewAI was installed and is working properly. Kickstart the crew of AI agents and begin task execution, run this from the root folder of your project:

```bash
crewai run
```

This command initializes the templatecrew Crew, assembling the agents and assigning them tasks as defined in your configuration.

## Running the the Node

Next, you need to test if the package has correctly picked up your crew configuration. There are two ways to run the node: HTTP server mode and registry mode.

1. To run the node in HTTP server mode, use:
> It is recommended to debug in HTTP mode, so you can use the Swagger UI to test your endpoints.
```bash
agentic run
```

> Ensure FastAPI and Uvicorn are installed as they are required for the HTTP server mode.

2. Go to [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) to interact with the local node.

3. Use your workflow name (not the node name) and try to run a job:
   - Uncollapse the /workflow/{workflow_name}/run section
   - Click on Try it out
   - Paster your workflow name
   - Modify the request body, to follow this structure:
     ```json
     {
       "topic": "test topic, type anything you want here"
     }
     ```
   - Click Execute
4. The node will respond with the job id, response should look like this:
   ```json
   "6cb2ceef-88ef-4206-8a4d-d6237dc15011"
   ```
5. Copy the job id (not the example one, the actual one you got) and paste it in the /job/{job_id} section, then click Execute.
6. The node will respond with the job status, response should look like this:
   ```json
   {
   "id": "6cb2ceef-88ef-4206-8a4d-d6237dc15011",
      "inputs": {
         "topic": "unicorns"
      },
      "status": "completed",
      "output": "# Unicorns in 2024: A Comprehensive Report ## 1. Genetic Engineering Advances\nIn 2024, researchers have made groundbreaking advancements in genetic engineering, particularly through the application of CRISPR technology. This has led to discussions surrounding the possibility of creating hybrid species that echo the mythical attributes of unicorns..."
   }
   ```

## Customizing

### Basic customization
> Before you start modifying the code, make sure the default template workflow runs without any issues.
- Modify `src/templatecrew/config/agents.yaml` to define your agents.
- Modify `src/templatecrew/config/tasks.yaml` to define your tasks.
- Modify `src/templatecrew/crew.py` to add your own logic, tools, and specific args.
- Modify `src/templatecrew/main.py` to add custom inputs for your agents and tasks.

Refer to crewAI [documentation](https://docs.crewai.com) for more information on how to customize your crew.

> **Important:** When you change the config of the node, run `pip install .` to update your node's package before running the node again.

### Advanced customization: using other people nodes as tools

> Our package is able to use other people nodes, which are connected to the registry, as tools. The nodes don't even have to be deployed - just attached to the registry. All you need to know the node's ID and the workflow's name.

The only thing you need to do is to have one of your agents to use the `RegistryAgenticNodeTool`. Here is an example of how to do it:

```python
@agent
def agent_name(self) -> Agent:
   return Agent(
      config=self.agents_config["config_name"],
      verbose=True, # Set to True to see the tool in action in the console
      tools=[
            RegistryAgenticNodeTool(
               node_ids=["node_id"], # The node's ID
               workflow="workflow_name", # The remote workflow's name (NOT the node's name)
            )
      ],
   )
```

**Things to consider:**
- The tool which is used here is backed into the package itself. So it is independent from the custom tools which you can still create freely withing your workflow.
- You can use remote nodes even if you are not connected to the registry.

## Running the Node in Registry Mode

1. **Add environment variables:**
```bash
export BASIC_AUTH_USERNAME=login_for_the_registry
export BASIC_AUTH_PASSWORD=password_for_the_registry
export REGISTRY_URL=wss://dev-agentic-registry.house-of-communication.world
export OPENAI_API_KEY=your_openai_api_key
```

You will know the login and password from the registry's admin (during the hackathon). Feel free to add other environment variables if you use them (e.g. `ANTHROPIC_API_KEY`, `SERPER_API_KEY`, etc.).

2. **Attach to the Registry:**
> Once you are ready to connect to the registry. This way others will be able to use your node by querying your node's ID directly, or via `RegistryAgenticNodeTool`.

   ```bash
   agentic run --mode=registry --registry=wss://dev-agentic-registry.house-of-communication.world
   ```

2. Visit the Swagger UI at [https://dev-agentic-registry.house-of-communication.world/swagger/index.html](https://dev-agentic-registry.house-of-communication.world/swagger/index.html).
3. Visit the Registry UI at [https://dev-agentic-registry.house-of-communication.world/](https://dev-agentic-registry.house-of-communication.world/).

Your node should now be visible in the Registry UI. If you can't find it among the green (running) nodes, double check the node name in `src/agentic/agentic_config.py`, line 23 (by default it is `TEMPLATE_NODE`, but you can change it to anything you want - it makes the node more recognizable for you on the registry).

## Alternative way: Running in Docker
> In order to run the node in Docker, you don't need to install any dependencies, except Docker Desktop.

1. Install Docker Desktop from [Docker website](https://www.docker.com/get-started) and run it.
2. Verify the installation 
```bash
docker --version
```
3. Clone the repository and navigate to the project directory containing the Dockerfile:
```bash
git clone https://github.com/pa1ar/kodo-template.git
cd kodo-template
```
4. Build the Docker image
```bash
docker build -t kodo-template .
```
- `-t kodo-template` assigns a name to your image for easier reference.
- The `.` specifies the current directory as the build context.

5.  Run the Docker Container 
Run it in HTTP server mode:
```bash
docker run -e OPENAI_API_KEY=your_key_here -p 8000:8000 kodo-template
```

Run in registry mode:
```bash
docker run -e OPENAI_API_KEY=your_key_here -e BASIC_AUTH_USERNAME=login_for_the_registry -e BASIC_AUTH_PASSWORD=password_for_the_registry -e REGISTRY_URL=wss://dev-agentic-registry.house-of-communication.world -p 8000:8000 kodo-template
```
- `-e OPENAI_API_KEY=your_key_here` sets the environment variable for the OpenAI API key.
- `-e BASIC_AUTH_USERNAME=login_for_the_registry` sets the environment variable for the registry's login.
- `-e BASIC_AUTH_PASSWORD=password_for_the_registry` sets the environment variable for the registry's password.
- `-e REGISTRY_URL=wss://dev-agentic-registry.house-of-communication.world` sets the environment variable for the registry's URL.
- `-p 8000:8000` maps port 8000 from the container to your machine.
- `kodo-template` is the name of the image you built earlier, it must match.
- The container starts, and the application docs becomes accessible at: [http://localhost:8000/docs](http://localhost:8000/docs)

> By default, the container runs in HTTP server mode.
> You can go to the Dockerfile and uncomment line 51 `CMD ["/bin/sh", "-c", "agentic run --mode=$MODE"]` to run in registry mode.
> However, better to change the name of the workflow first, otherwise the name of the node on the registry will be "TEMPLATE_NODE".

> **Warning:** When running in HTTP server mode, even after stopping the container, the port 8000 will be used by the container, so you need to remove the container manually. See below for the commands.

6. After you are done, you can stop the container with `CTRL+C` 
7. Docker is not going to remove the container automatically, so you need to remove it manually. You can do it with GUI of your Docker Desktop. Or with the following commands:

   - First, identify the container id with:

     ```bash
     docker ps
     ```

   - Then, stop and remove the container with:

     ```bash
     docker stop <container_id>
     docker rm <container_id>
     ```

   - You can also stop and remove all the containers with the following command:

      ```bash
      docker stop $(docker ps -a -q)
      docker rm $(docker ps -a -q)
      ```

   - And prune the system from all unused images with:

      ```bash
      docker system prune -a
      ```

## Support

For support, questions, or feedback regarding the Templatecrew Crew or crewAI:
- Visit [masumi homepage](https://www.masumi.network/)
- Join our Discord (if you know you know)
- Visit CrewAI [documentation](https://docs.crewai.com)