SELECT
    cp.cd_categoria,
    cp.tp_categoria,
    cp.ds_categoria,
    cp.dt_inicio,
    cp.dt_termino,
    cp.st_categoria, 
    NVL(COUNT(s.nr_sac), 0) AS total_chamados
FROM mc_categoria_prod cp
LEFT JOIN mc_produto p 
    ON cp.cd_categoria = p.cd_categoria
LEFT JOIN mc_sgv_sac s 
    ON p.cd_produto = s.cd_produto
GROUP BY 
    cp.cd_categoria,
    cp.tp_categoria,
    cp.ds_categoria,
    cp.dt_inicio,
    cp.dt_termino,
    cp.st_categoria
ORDER BY 
    cp.cd_categoria;