# Utility Scripts

## `convert_greek_encoding.jl`

To convert a Unicode Greek text to BetaCode:

```
julia --project=. utilities/convert_greek_encoding.jl -i PATH/TO/UNICODE/TEXT.txt -o PATH/TO/BETACODE/TEXT.txt -d beta
```

To convert a BetaCode Greek text to Unicode:

```
julia --project=. utilities/convert_greek_encoding.jl -i PATH/TO/BETACODE/TEXT.txt -o PATH/TO/UNICODE/TEXT.txt -d unicode
```