#!/bin/bash

### Process docker secrets
source secrets

### Start apache
apache2-foreground
