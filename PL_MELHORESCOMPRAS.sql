
DECLARE
    CURSOR c_sac_detalhado IS
        SELECT 
            s.nr_sac,                         
            s.dt_abertura_sac,                
            s.hr_abertura_sac,                
            s.tp_sac,                         
            p.cd_produto,                     
            p.ds_produto,                     
            p.vl_unitario,                    
            p.vl_perc_lucro,                  
            c.nr_cliente,                     
            c.nm_cliente,                     
            e.sg_estado,                      
            e.nm_estado                       
        FROM mc_sgv_sac s
        JOIN mc_produto p   ON s.cd_produto = p.cd_produto
        JOIN mc_cliente c   ON s.nr_cliente = c.nr_cliente
        JOIN mc_end_cli ec  ON c.nr_cliente = ec.nr_cliente
        JOIN mc_logradouro l ON ec.cd_logradouro_cli = l.cd_logradouro
        JOIN mc_bairro b    ON l.cd_bairro = b.cd_bairro
        JOIN mc_cidade ci   ON b.cd_cidade = ci.cd_cidade
        JOIN mc_estado e    ON ci.sg_estado = e.sg_estado;

    -- Variáveis para armazenar valores transformados
    v_ds_tipo_classificacao_sac VARCHAR2(30);
    v_vl_unitario_lucro_produto NUMBER(10,2);
    v_vl_icms_produto           NUMBER(10,2);

BEGIN
    FOR r_sac IN c_sac_detalhado LOOP
        
        -- Regra 1: transformar TP_SAC em descrição
        IF r_sac.tp_sac = 'S' THEN
            v_ds_tipo_classificacao_sac := 'SUGESTÃO';
        ELSIF r_sac.tp_sac = 'D' THEN
            v_ds_tipo_classificacao_sac := 'DÚVIDA';
        ELSIF r_sac.tp_sac = 'E' THEN
            v_ds_tipo_classificacao_sac := 'ELOGIO';
        ELSE
            v_ds_tipo_classificacao_sac := 'CLASSIFICAÇÃO INVÁLIDA';
        END IF;

        -- Regra 2: calcular valor unitário do lucro do produto
        v_vl_unitario_lucro_produto := (r_sac.vl_perc_lucro / 100) * r_sac.vl_unitario;

        -- Regra 3: valor do ICMS deve ser mantido vazio (NULL)
        v_vl_icms_produto := NULL;

        -- Inserir na tabela MC_SGV_OCORRENCIA_SAC
        INSERT INTO mc_sgv_ocorrencia_sac (
            nr_ocorrencia_sac,
            dt_abertura_sac,
            hr_abertura_sac,
            ds_tipo_classificacao_sac,
            cd_produto,
            ds_produto,
            vl_unitario_produto,
            vl_perc_lucro,
            vl_unitario_lucro_produto,
            sg_estado,
            nm_estado,
            nr_cliente,
            nm_cliente,
            vl_icms_produto
        ) VALUES (
            r_sac.nr_sac,
            r_sac.dt_abertura_sac,
            r_sac.hr_abertura_sac,
            v_ds_tipo_classificacao_sac,
            r_sac.cd_produto,
            r_sac.ds_produto,
            r_sac.vl_unitario,
            r_sac.vl_perc_lucro,
            v_vl_unitario_lucro_produto,
            r_sac.sg_estado,
            r_sac.nm_estado,
            r_sac.nr_cliente,
            r_sac.nm_cliente,
            v_vl_icms_produto
        );

    END LOOP;

    COMMIT; -- Confirma as inserções
END;
/


 
    