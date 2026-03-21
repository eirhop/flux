Dev review feedback:
- Duplicate type from asset.ex -> @valid_kinds [:materialized, :view, :ephemeral]. please reuse type from asset.ex
- In tests add logging of what test and results so that i can see results when running tests. 



Natural next steps:
1. Implement dependency existence/graph construction on top of __flux_assets__/0
2. Add a registry layer for Flux.list_assets/0
3. Add richer asset validation rules once cross-module planning starts