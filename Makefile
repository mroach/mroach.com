# Creates a favicon with the top 75% as black and a coloued stripe on the bottom.
# An icon file supports multiple resolutions, so we'll generate an ico file for
# each size, combine those into one final favicon, and delete the individuals.
MAIN_FILL := black
RECT_FILL := rgb(58,110,165)

RECT_Y = $$(( $(SIZE) / 4 ))
OFFSET_Y = $$(( $(SIZE) - $(RECT_Y) ))
SIZES := 16 32 48 64

# create a list of targets from sizes. e.g. 64 => favicon-64.ico
favicon-targets = $(addsuffix .ico, $(addprefix favicon-, $(SIZES)))

PORT ?= 1313
HUGO_VERSION ?= 0.105.0

all: static/favicon.ico static/apple-touch-icon.png

clean:
	-rm static/favicon.ico
	-rm static/apple-touch-icon.png
	-rm $(favicon-targets)

icon/%:
	convert -size $(SIZE)x$(SIZE) \
		xc:$(MAIN_FILL) \
		-fill "$(RECT_FILL)" \
		-draw "rectangle 0,$(OFFSET_Y), $(SIZE),$(SIZE)" \
		$*

# size is the wildcard. set the SIZE var based on its value
favicon-%.ico:
	$(MAKE) icon/$(@F) SIZE=$*

static/favicon.ico: $(favicon-targets)
	convert $(favicon-targets) static/favicon.ico
	rm $(favicon-targets)

static/apple-touch-icon.png:
	$(MAKE) icon/static/apple-touch-icon.png SIZE=180

serve:
	docker run --rm -v $(PWD):/src -p $(PORT):1313 klakegg/hugo:$(HUGO_VERSION) serve

.PHONY: serve
