
# ENTTAC Dataset

This repository contains the ENTTAC dataset, organized by collection sites and dates. The raw data is collected from sensors, and processed data folders are set up for each task, aligning with robotics practices.

## File Structure

```
.
└── data
    ├── site_CMUCampus
    │   ├── 2024_04_16
    │   │   ├── collect_01
    │   │   │   ├── raw
    │   │   │   └── processed
    │   │   └── collect_02
    │   │       ├── raw
    │   │       └── processed
    │   └── 2024_05_03
    │       ├── collect_01
    │       │   ├── raw
    │       │   └── processed
    │       └── collect_02
    │           ├── raw
    │           └── processed
    ├── site_FlagstaffHill
    │   ├── 2024_05_03
    │   │   ├── collect_01
    │   │   │   ├── raw
    │   │   │   └── processed
    │   │   └── collect_02
    │   │       ├── raw
    │   │       └── processed
    │   └── 2024_06_04
    │       ├── collect_01
    │       │   ├── raw
    │       │   └── processed
    │       └── collect_02
    │           ├── raw
    │           └── processed
    └── site_FrickPark
        ├── 2024_05_14
        │   ├── collect_01
        │   │   ├── raw
        │   │   └── processed
        │   └── collect_02
        │       ├── raw
        │       └── processed
        └── 2024_06_10
            ├── collect_01
            │   ├── raw
            │   └── processed
            └── collect_02
                ├── raw
                └── processed
```

## Pulling Data

To pull specific data from the ENTTAC dataset using DVC, follow these steps:

### Prerequisites

Ensure you have DVC installed and configured. If not, install DVC using:

```bash
pip install dvc
```

### Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/your-username/enttac-dataset.git
cd enttac-dataset
```

### Pull Specific `collect` Folder Data

To pull data for a specific `collect` folder, use the `dvc pull` command followed by the path to the specific `.dvc` file. For example, to pull data for `site_CMUCampus/2024_04_16/collect_01`:

```bash
dvc pull data/site_CMUCampus/2024_04_16/collect_01.dvc
```

This command will pull the raw data related to the specified `collect` folder.

### Pull All Data for a Specific Site

If you want to pull all data for a specific site, navigate to the site's directory and use the `dvc pull` command:

```bash
cd data/site_CMUCampus
dvc pull
```

This command will pull all raw data related to the `site_CMUCampus`.

### Processing Data

Processed data for each task will be stored in the `processed` folders. These folders will contain the output of preprocessing, feature extraction, and other data processing steps. Ensure your data processing scripts save their outputs to the appropriate `processed` folders.

## Example Data Processing Stage

Here is an example of how to define a stage in `dvc.yaml` for preprocessing data:

```yaml
stages:
  preprocess_CMUCampus_0416:
    cmd: python preprocess.py data/site_CMUCampus/2024_04_16/collect_01/raw data/site_CMUCampus/2024_04_16/collect_01/processed
    deps:
      - data/site_CMUCampus/2024_04_16/collect_01/raw
    outs:
      - data/site_CMUCampus/2024_04_16/collect_01/processed
```

To run this preprocessing stage and ensure the necessary data is pulled:

```bash
dvc repro preprocess_CMUCampus_0416
```

This command will pull the raw data for `site_CMUCampus/2024_04_16/collect_01`, run the preprocessing script, and store the results in the `processed` folder.

## Additional Information

- Ensure that any Excel or YAML configuration files are added directly to Git and not tracked by DVC to avoid unnecessary versioning conflicts.

```bash
git add path/to/your/file.xlsx
git add path/to/your/file.yaml
git commit -m "Add Excel and YAML configuration files"
```

- Check your `.gitignore` and `.dvcignore` files to make sure they do not include the files you want to keep track of in Git only.

For any further assistance or questions, please refer to the [DVC documentation](https://dvc.org/doc) or open an issue in this repository.
