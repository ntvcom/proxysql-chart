# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automating Helm chart packaging and publishing.

## Workflows

### 1. package-and-push.yml (Recommended)

A simple workflow that packages and pushes the Helm chart to GitHub Container Registry (GHCR).

**Triggers:**
- Push to `main` branch
- Git tags starting with `v*`

**What it does:**
1. Packages the Helm chart using `helm package`
2. Pushes the packaged chart to GHCR as an OCI artifact

### 2. release.yml (Full-featured)

A comprehensive workflow that includes chart packaging, GHCR publishing, and GitHub Pages deployment.

**Triggers:**
- Push to `main` branch
- Git tags starting with `v*`
- Pull requests to `main` branch

**What it does:**
1. Packages the Helm chart
2. Pushes to GHCR
3. Creates a traditional Helm repository index on GitHub Pages

## Required Permissions

The workflows require the following GitHub repository settings:

1. **Actions permissions**: Enable "Read and write permissions" for GitHub Actions
2. **Pages**: Enable GitHub Pages (for the full release workflow)
3. **Packages**: The `GITHUB_TOKEN` automatically has package write permissions

## Chart Versioning

The workflows automatically detect the chart version from `Chart.yaml` and use it for tagging the OCI artifact.

## Usage After Setup

Once the workflows are set up:

1. **Manual trigger**: Push to main branch or create a git tag
2. **Automatic publishing**: Charts will be available at `ghcr.io/ntvcom/proxysql`
3. **Installation**: Users can install with `helm install my-release oci://ghcr.io/ntvcom/proxysql`

## Customization

To customize for your repository:

1. Update the repository owner in README.md examples
2. Modify workflow triggers as needed
3. Adjust chart naming or versioning strategy if required
