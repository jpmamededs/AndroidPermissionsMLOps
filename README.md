# MLOps Project

This project implements an end-to-end Machine Learning pipeline in production using Azure Machine Learning. The goal is to demonstrate MLOps best practices, including infrastructure automation, CI/CD, and experiment versioning.

## What it does

The project trains a RandomForest model for classification using the `android-permissions-v2` dataset. The entire model lifecycle is automated, from infrastructure provisioning to trained model deployment.

The model is only approved if it achieves at least 85% accuracy on the test set. Otherwise, the pipeline fails and prevents deployment of an underperforming model.

## Architecture

The solution is organized as follows:

```
MLOpsProject/
├── src/                    # ML source code
│   ├── preprocess.py       # Data loading and preparation
│   ├── train.py            # Model training and validation
│   └── score.py            # Inference
├── infra/                  # Infrastructure as code
│   └── resources.tf        # Azure resources (Terraform)
├── pipelines/              # Pipeline definitions
│   ├── job.yml             # Training job (Azure ML)
│   └── deployment.yml      # Deployment pipeline
├── CICD.yml                # CI/CD pipeline (Azure DevOps)
├── infra.yml               # Infrastructure pipeline
└── environment.yml         # Python dependencies (Conda)
```

## Infrastructure

Infrastructure is automatically provisioned on Azure using Terraform. Created resources include:

- **Resource Group**: Logical container for all resources
- **Machine Learning Workspace**: Environment for experiments
- **Storage Account**: Storage for datasets and artifacts
- **Key Vault**: Secure credential management
- **Application Insights**: Monitoring and telemetry

To provision infrastructure manually:

```bash
cd infra
terraform init
terraform plan
terraform apply
```

## Local environment setup

Create the Conda environment with required dependencies:

```bash
conda env create -f environment.yml
conda activate mlops-env
```

## Running training locally

After activating the environment, you can train the model locally:

```bash
cd src
python train.py --data_path /path/to/your/dataset.csv
```

The script will:
1. Load and preprocess the data
2. Split into train/test (80/20)
3. Train a RandomForest with 200 trees
4. Calculate metrics (accuracy, precision, recall, F1)
5. Log everything to MLflow
6. Validate that accuracy is >= 85%

## CI/CD

The project has two main pipelines in Azure DevOps:

### Infrastructure Pipeline (`infra.yml`)

Runs automatically when there are changes in the `infra/` folder. Validates and applies Terraform configurations.

### Integration Pipeline (`CICD.yml`)

Runs automatically on commits to the `master` branch. Performs:

1. Creates training job in Azure ML
2. Waits for training completion
3. Validates model metrics
4. Only approved models proceed to next steps

## Metrics and Monitoring

Metrics logged for each experiment include:
- **Accuracy**: Percentage of correct predictions
- **Precision**: Quality of positive predictions
- **Recall**: Coverage of actual classes
- **F1 Score**: Harmonic mean between precision and recall

All experiments are registered in the Azure ML Workspace and can be tracked through the MLflow UI.

## Prerequisites

- Active Azure Subscription
- Azure DevOps configured
- Service Principal with appropriate permissions
- Terraform installed (version 1.7.0 or higher)

### Required variables in Azure DevOps

Configure the following variables in your pipeline:

- `RESOURCE_GROUP`: Resource group name
- `WORKSPACE_NAME`: Azure ML workspace name
- Service Connection: `AzResourceManager`

## Dataset

The project uses the `android-permissions-v2` dataset, which must be registered as a Data Asset in Azure ML. The target column is `Result`.

To use your own dataset, adjust the `pipelines/job.yml` file and ensure your structure has a `Result` column for classification.

## Contributing

1. Create a branch for your feature
2. Commit your changes
3. Open a Pull Request
4. Wait for automated test approval

## Troubleshooting

**Pipeline fails with authentication error**: Verify that the Service Principal has the correct permissions (Contributor on the Resource Group).

**Model rejected**: If accuracy is below 85%, review the hyperparameters in `train.py` or consider additional feature engineering.

**Terraform error**: Ensure the backend is configured correctly and there are no naming conflicts in Azure resources.

## License

This project is available for educational purposes and MLOps concept demonstration.
