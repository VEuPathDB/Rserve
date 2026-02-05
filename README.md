# Rserve Docker Image

Docker image for Rserve with Bioconductor packages (DESeq2, SummarizedExperiment), SpiecEasi, VEuPathDB utilities (plot.data, veupathUtils, microbiomeComputations), and other R packages commonly used for microbiome and genomic data analysis.

Based on `rocker/r-ver:4.4.2` (R 4.4.2 on Ubuntu 24.04).

## Prerequisites

- Docker installed and running
- (Optional) GitHub Personal Access Token for extended debugging needing repeated build cycles and frequent GitHub pulls

## Building the Image

### Standard Build

If you're in the this directory:

```bash
docker build -t rserve .
```

### Using --no-cache

R package installations can fail silently or cache incomplete builds. Using `--no-cache` ensures a clean build during debugging (but takes longer, of course):

```bash
docker build -t rserve . --no-cache
```

### Development Build (with GitHub PAT)

For frequent development builds, provide a GitHub Personal Access Token to avoid API rate limits (60 unauthenticated vs 5000 authenticated requests/hour):

```bash
docker build --build-arg GITHUB_PAT=$GITHUB_TOKEN -t rserve .
```

**Note**: The PAT is passed as a build argument (`ARG`) and is not stored in the final image layers. It's only used during the build process.

**When to use**:
- Development/debugging with frequent rebuilds
- When you hit GitHub API rate limit errors during build (typically opaque error messages at package download time)

**When to skip**:
- CI/Jenkins builds (usually work fine without it, assuming no rate limit issues)
- Production builds (if rate limits aren't a concern)

### Reading/keeping the build log

The pretty progress output is not useful for spotting R installation errors. Use a flat version sent to a file:

```bash
docker build --build-arg GITHUB_PAT=$GITHUB_TOKEN --no-cache -t rserve . 2>&1 | tee /tmp/docker-build-attempt-01.log
```

You can watch it scroll and/or inspect the tmp file with `less`/`grep` etc. in another terminal.

## Running the Container

### Run Rserve Service

Start Rserve daemon listening on port 6311:

```bash
docker run --rm rserve:latest
```

Or with port mapping:

```bash
docker run --rm -p 6311:6311 rserve:latest
```

### Interactive R Shell

Get an interactive R shell for testing packages:

```bash
docker run --rm -it rserve R
```

Example session:
```r
> library(DESeq2)
> library(SpiecEasi)
> packageVersion("veupathUtils")
```

### Bash Shell

Get a bash shell for debugging:

```bash
docker run --rm -it rserve /bin/bash
```

## Installed Packages

### Core Packages
- **Rserve** (1.8-9): R server for remote R sessions
- **plot.data** (v5.6.5): VEuPathDB plotting utilities
- **microbiomeComputations** (v5.1.6.5): Microbiome analysis functions, includes Maaslin2
- **veupathUtils** (v2.9.0): VEuPathDB utility functions

### Bioconductor Packages
- **DESeq2**: Differential gene expression analysis
- **SummarizedExperiment**: Container for genomic data
- **S4Vectors**, **IRanges**, **GenomeInfoDb**: Core Bioconductor infrastructure

### Network Analysis
- **SpiecEasi** (v1.0.7): Sparse Inverse Covariance for Ecological Statistical Inference

### CRAN Packages
- Data manipulation: `dplyr`, `data.table`, `readr`
- Utilities: `jsonlite`, `bit64`, `digest`, `Hmisc`, `Rcpp`, `remotes`

## Troubleshooting

### S4Vectors/DESeq2 Compilation Errors

#### Problem

When building on Ubuntu 24.04 with gcc 13.3.0 and R 4.4.2 (rocker/r-ver:4.4.2), S4Vectors compilation fails with:

```
error: format not a string literal and no format arguments [-Werror=format-security]
```

This cascading failure prevents installation of packages that depend on S4Vectors:
- "Skipping 1 packages not available: Seqinfo"
- "packages 'Seqinfo' are not available"
- "ERROR: dependency 'IRanges' is not available for package 'GenomeInfoDb'"
- "ERROR: dependency 'SummarizedExperiment' is not available for package 'DESeq2'"

#### Root Cause

Bioconductor S4Vectors code calls `error(variable)` instead of the correct `error("%s", variable)` format. Ubuntu 24.04's default compiler flags include `-Werror=format-security`, which treats this as a fatal error rather than a warning.

**Dependency chain**: S4Vectors → IRanges → GenomeInfoDb → SummarizedExperiment → DESeq2

This is a long-standing issue in the Bioconductor codebase (since 2013+) that affects various Ubuntu versions with strict compiler security settings.

#### Solution

Override CFLAGS in `~/.R/Makevars` to remove `-Werror=format-security` while keeping other security flags:

**In Dockerfile** (see lines 19-27):
```dockerfile
RUN mkdir -p /root/.R && \
    echo "CFLAGS = -g -O2 -fstack-protector-strong -Wformat -Wdate-time -D_FORTIFY_SOURCE=2" > /root/.R/Makevars
```

**For local R installation**:
```bash
mkdir -p ~/.R
echo "CFLAGS = -g -O2 -fstack-protector-strong -Wformat -Wdate-time -D_FORTIFY_SOURCE=2" > ~/.R/Makevars
```

This removes `-Werror=format-security` from the default rocker/r-ver:4.4.2 flags while preserving other security features:
- Default flags: `-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2`
- Our override: `-g -O2 -fstack-protector-strong -Wformat -Wdate-time -D_FORTIFY_SOURCE=2` (removed `-Werror=format-security`)

#### Affected Environments
- Ubuntu 24.04
- gcc 13.3.0
- R 4.4.2
- rocker/r-ver:4.4.2
- Bioconductor packages: S4Vectors, IRanges, GenomeInfoDb, SummarizedExperiment, DESeq2

#### Search Keywords

If you encountered this issue, you may have searched for:
- "S4Vectors compilation error"
- "S4Vectors compilation failed"
- "DESeq2 won't install"
- "DESeq2 installation error Ubuntu"
- "Bioconductor package won't compile"
- "IRanges compilation error"
- "GenomeInfoDb installation fails"
- "SummarizedExperiment installation fails"
- "error: format not a string literal and no format arguments"
- "Werror=format-security"
- "Bioconductor format-security"
- "Seqinfo not available"
- "packages 'Seqinfo' are not available"
- "Skipping 1 packages not available: Seqinfo"

### GitHub Rate Limits

If you encounter GitHub API rate limit errors during build:

```
Error: Failed to install 'unknown package' from GitHub:
  HTTP error 403.
  API rate limit exceeded
```

**Solution**: Use a GitHub Personal Access Token (see "Development Build" section above).

## Notes

- This image uses specific package versions for reproducibility:
  - plot.data: v5.6.5
  - microbiomeComputations: v5.1.6.5 (includes Maaslin2 and veupathUtils v2.9.0)
  - SpiecEasi: v1.0.7
- The S4Vectors compilation workaround should be removed once Bioconductor fixes their code
- Rserve listens on port 6311 by default
- Configuration file: `/etc/Rserv.conf`
- Working directory: `/opt/rserve/work`
- Library files: `/opt/rserve/lib`
