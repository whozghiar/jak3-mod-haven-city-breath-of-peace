("CTYPESA.DGO"
 ("tpage-957.go"
  ;; MOD peaceful-haven-city -- Hellcat texture pages (home: CTYCARC, never loaded by the city)
  "tpage-950.go"
  "tpage-951.go"
  ;; Art groups must stay sorted by decreasing size (DGO load buffers shrink to the object two
  ;; slots earlier): crimson-guard-ag 288976, hellcat-ag 141856, then the shield spheres.
  ;; The Hellcat merc geometry reaches ctypesa.fr3 through "extra_art_groups_by_dgo"
  ;; (decompiler/config/jak3/jak3_config.jsonc): run `task extract` after changing this list.
  "crimson-guard-ag.go"
  "hellcat-ag.go" ;; MOD peaceful-haven-city -- Freedom League Hellcat
  "shield-sphere-explode-ag.go"
  "shield-sphere-distort-ag.go"
  "shield-sphere-ag.go"
  "ctypesa.go"
 ))
