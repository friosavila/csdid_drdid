help: code/csdid.sthlp code/drdid.sthlp
code/%.sthlp: %.md smcl.lua
	pandoc -f gfm -t smcl.lua $< > $@
smcl.lua:
	curl -sLo $@ "https://raw.githubusercontent.com/korenmiklos/pandoc-smcl/master/smcl.lua"