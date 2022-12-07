# convert from anon_chi to CHI

    Code
      tibble::tibble(anon_chi = anon_chi) %>% dplyr::mutate(chi = convert_anon_chi_to_chi(
        anon_chi))
    Output
      # A tibble: 5 x 2
        anon_chi         chi       
        <chr>            <chr>     
      1 MDkwMTk2NTI4Ng== 0901965286
      2 MDYwODYyNjgwNQ== 0608626805
      3 MDkwNDc0NjIxNg== 0904746216
      4 MTgxMjYzMTE0Ng== 1812631146
      5 MjAwNDUzMzQ0Nw== 2004533447

# convert from CHI to anon_chi

    Code
      tibble::tibble(chi = chi) %>% dplyr::mutate(anon_chi = convert_chi_to_anon_chi(
        chi))
    Output
      # A tibble: 5 x 2
        chi        anon_chi        
        <chr>      <chr>           
      1 0901965286 MDkwMTk2NTI4Ng==
      2 0608626805 MDYwODYyNjgwNQ==
      3 0904746216 MDkwNDc0NjIxNg==
      4 1812631146 MTgxMjYzMTE0Ng==
      5 2004533447 MjAwNDUzMzQ0Nw==

