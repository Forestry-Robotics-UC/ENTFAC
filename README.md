
# ENTFAC Dataset

This repository contains the ENTFAC dataset, organized by collection sites and dates. The raw data is collected from sensors, and processed data folders are set up for each task, aligning with robotics practices.  For dataset access, request [here](https://forms.gle/cJ6XuxaEUu76NkH77)

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

## Setting Up DVC

To access the ENTFAC dataset, follow these steps to install DVC and pull the datasets.

### Install DVC

Ensure you have DVC installed. If not, install it using pip:

```bash
pip install dvc
```

### Pull Data from the Remote

To pull the data for this repository, use the following commands. Ensure you are in the root directory of the cloned repository.

```bash
dvc pull
```

This command will pull all the data tracked by DVC for the ENTFAC dataset.

## Pulling Specific Data

To pull specific data from the ENTFAC dataset using DVC, follow these steps:

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

## Additional Information

For any further assistance or questions, please refer to the [DVC documentation](https://dvc.org/doc) or open an issue in this repository.
