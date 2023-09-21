CHANNELS    = $(addprefix -c ,$(shell tr '\n' ' ' <$(RECIPE_DIR)/channels)) -c local
METAJSON    = $(RECIPE_DIR)/meta.json
RECIPEFILES = $(addprefix $(RECIPE_DIR)/,conda_build_config.yaml meta.yaml)
TARGETS     = env meta package

export RECIPE_DIR := $(shell cd ./recipe && pwd)

spec = $(call val,name)$(2)$(call val,version)$(2)$(call val,$(1))
val  = $(shell jq -r .$(1) $(METAJSON))

.PHONY: $(TARGETS)

all:
	$(error Valid targets are: $(TARGETS))

env: package
	conda create -y -n $(call spec,buildnum,-) $(CHANNELS) $(call spec,build,=)

meta: $(METAJSON)

package: meta
	conda build $(CHANNELS) --error-overlinking --override-channels $(RECIPE_DIR)

$(METAJSON): $(RECIPEFILES)
	condev-meta
