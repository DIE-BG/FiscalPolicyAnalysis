!measurement_variables
m_GDP_star_SM_yoy,
m_i_star,
m_pi_star_yoy,
m_IPub_ratio,
m_IngT_ratio,
m_Gfun_ratio,
m_DPE_ratio,
m_Rem_ratio,
m_DPI_ratio,
m_AEN_ratio,
m_AIN_ratio,
m_i,
m_e_yoy,
m_PREM,
m_pi_yoy,
m_GDP_SM_yoy,
m_IPriv_ratio

!measurement_equations
m_GDP_star_SM_yoy = GDP_star_SM_yoy;
m_i_star = i_star;
m_pi_star_yoy = pi_star_yoy;
m_IPub_ratio = IPub_ratio;
m_IngT_ratio = IngT_ratio;
m_Gfun_ratio = Gfun_ratio;
m_DPE_ratio = DPE_ratio;
m_Rem_ratio = Rem_ratio;
m_DPI_ratio = DPI_ratio;    
m_AEN_ratio = AEN_ratio;
m_AIN_ratio = AIN_ratio;
m_i = i;
m_e_yoy = e_yoy;
m_PREM = PREM;
m_pi_yoy = pi_yoy;
m_GDP_SM_yoy = GDP_SM_yoy;
m_IPriv_ratio = IPriv_ratio;


%% 1. Variables
!transition-variables
'Tasa de crecimiento interanual de la suma movil de 4T del PIB externo (%)'                     GDP_star_SM_yoy,
'Tasa de interés externa (%)'                                                                   i_star,
'Tasa de inflación subyacente externa (%)'                                                      pi_star_yoy,
'Cociente de Inversión pública a PIB nominal doméstico (%)'                                     IPub_ratio,
'Cociente de Ingresos totales a PIB nominal doméstico (%)'                                      IngT_ratio,
'Cociente de Gasto de funcionamiento a PIB nominal doméstico (%)'                               Gfun_ratio,
'Cociente de Deuda pública externa a PIB nominal doméstico (%)'                                 DPE_ratio,
'Cociente de Remesas a PIB nominal doméstico (%)'                                               Rem_ratio,
'Cociente de Deuda pública interna a PIB nominal doméstico (%)'                                 DPI_ratio,
'Cociente de Activos externos netos a PIB nominal doméstico (%)'                                AEN_ratio,
'Cociente de Activos internos netos a PIB nominal doméstico (%)'                                AIN_ratio,
'Tasa de interés de política monetaria (%)'                                                     i,
'Tasa de depreciación cambiaria (%)'                                                            e_yoy,
'Prima por riesgo país (%)'                                                                     PREM,
'Inflación doméstica (%)'                                                                       pi_yoy,
'Tasa de crecimiento interanual de la suma movil de 4T del PIB doméstico (%)'                   GDP_SM_yoy,
'Cociente de Inversión privada a PIB nominal doméstico (%)'                                     IPriv_ratio,
'Crecimiento económico externo (ola)'                                                           GDP_star_ola,
'Tasa de interés externa (ola)'                                                                 i_star_ola,
'Inflación externa (ola)'                                                                       pi_star_ola,
'Inversió pública (ola)'                                                                        IPub_ola,
'Ingresos totales (ola)'                                                                        IngT_ola,
'Gasto de funcionamiento (ola)'                                                                 GFun_ola,
'Deuda pública externa (ola)'                                                                   DPE_ola,
'Remesas (ola)'                                                                                 Rem_ola,
'Deuda pública interna (ola)'                                                                   DPI_ola,
'Activos externos netos (ola)'                                                                  AEN_ola,
'Activos internos netos (ola)'                                                                  AIN_ola,
'Tasa de interés líder de política monetaria (ola)'                                             i_ola,
'Depreciación monetaria (ola)'                                                                  e_ola,
'Prima por riesgo país (ola)'                                                                   PREM_ola,
'Inflación domésticoa (ola)'                                                                    pi_ola,
'Crecimiento económico (ola)'                                                                   GDP_ola,
'Inversió privada (ola)'                                                                        IPriv_ola,
'Base monetaria ampliada (ola)'                                                                 AMB_ola,
'Tipo de cambio real (ola)'                                                                     z_ola,
'Deuda pública externa consolidada (ola)'                                                       DPEC_ola,
'Deuda pública interna consolidada (ola)'                                                       DPIC_ola,
'Deuda pública total consolidada (ola)'                                                         DPTC_ola,
'Deuda pública total (ola)'                                                                     DPT_ola,
'Inversion total (ola)'                                                                         ITotal_ola,
'Déficit (ola)'                                                                                 Def_ola,
'Cociente Base monetaria ampliada a PIB nominal doméstico (%)'                                  AMB_ratio,
'Tasa de depreciación del tipo de cambio real (%)'                                              z,
'Cociente de Deuda pública externa consolidada a PIB nominal doméstico (%)'                     DPEC_ratio,
'Cociente de Deuda pública interna consolidada a PIB nominal doméstico (%)'                     DPIC_ratio,
'Cociente de Deuda pública total consolidada a PIB nominal doméstico (%)'                       DPTC_ratio,
'Cociente de Deuda pública total a PIB nominal doméstico (%)'                                   DPT_ratio,
'Cociente de Inversión total a PIB nominal doméstico (%)'                                       ITotal_ratio,
'Cociente de Déficit a PIB nominal doméstico (%)'                                               Def_ratio

%% 2. Shocks
!transition-shocks
'Residuo del crecimiento económico'                   u1,
'Residuo de la tasa de interés externa'               u2,
'Residuo de la Inflación externa'                     u3,
'Residuo de la inversión pública'                     u4,
'Residuo del ingreso total'                           u5,
'Residuo del gasto de funcionamiento'                 u6,
'Residuo de la deuda pública externa'                 u7,
'Residuo de las remesas'                              u8,
'Residuo de la deuda publica interna'                 u9,
'Residuo de los activos externos netos'               u10,
'Residuo de los activos internos netos'               u11,
'Residuo de la tasa de interés líder'                 u12,
'Residuo de la depreciacion nominal'                  u13,
'Residuo de la prima por riesgo país'                 u14,
'Residuo de la inflación doméstica'                   u15,
'Residuo del crecimiento económico'                   u16,
'Residuo de la inversión privada'                     u17

%% 3. Parameters
!parameters
    a1_1,
    a2_1,
    a3_1,
    a4_1,
    a5_1,
    a6_1,
    a7_1,
    a8_1,
    a9_1,
    a9_2,
    a9_3,
    a10_1,
    a10_2,
    a10_3,
    a11_1,
    a11_2,
    a11_3,
    a11_4,
    a12_1,
    a12_2,
    a12_3,
    a12_4,
    a13_1,
    a13_2,
    a13_3,
    a14_1,
    a14_2,
    a15_1,
    a15_2,
    a15_3,
    a15_4,
    a15_5,
    a16_1,
    a16_2,
    a16_3,
    a16_4,
    a16_5,
    a17_1,
    a17_2,
    a17_3,
    a17_4

!transition-equations

    % Construction of ola variables
    % GDP_star_ola
    GDP_star_ola = GDP_star_SM_yoy - (GDP_star_SM_yoy{-4} + GDP_star_SM_yoy{-3} + GDP_star_SM_yoy{-2} + GDP_star_SM_yoy{-1})/4;

    % i_star_ola
    i_star_ola = i_star - (i_star{-4} + i_star{-3} + i_star{-2} + i_star{-1})/4;
    
    % pi_star_ola
    pi_star_ola = pi_star_yoy - (pi_star_yoy{-4} + pi_star_yoy{-3} + pi_star_yoy{-2} + pi_star_yoy{-1})/4;
    
    % IPub_ola
    IPub_ola = IPub_ratio - (IPub_ratio{-4} + IPub_ratio{-3} + IPub_ratio{-2} + IPub_ratio{-1})/4;
    
    % IngT_ola
    IngT_ola = IngT_ratio - (IngT_ratio{-4} + IngT_ratio{-3} + IngT_ratio{-2} + IngT_ratio{-1})/4;
    
    % Gfun_ratio
    GFun_ola = Gfun_ratio - (Gfun_ratio{-4} + Gfun_ratio{-3} + Gfun_ratio{-2} + Gfun_ratio{-1})/4;
    
    % DPE_ola
    DPE_ola = DPE_ratio - (DPE_ratio{-4} + DPE_ratio{-3} + DPE_ratio{-2} + DPE_ratio{-1})/4;
    
    % Rem_ola
    Rem_ola = Rem_ratio - (Rem_ratio{-4} + Rem_ratio{-3} + Rem_ratio{-2} + Rem_ratio{-1})/4;
    
    % DPI_ola
    DPI_ola = DPI_ratio - (DPI_ratio{-4} + DPI_ratio{-3} + DPI_ratio{-2} + DPI_ratio{-1})/4;
    
    % AEN_ola
    AEN_ola = AEN_ratio - (AEN_ratio{-4} + AEN_ratio{-3} + AEN_ratio{-2} + AEN_ratio{-1})/4;
    
    % AIN_ola
    AIN_ola = AIN_ratio - (AIN_ratio{-4} + AIN_ratio{-3} + AIN_ratio{-2} + AIN_ratio{-1})/4;
    
    % i_ola
    i_ola = i - (i{-4} + i{-3} + i{-2} + i{-1})/4;
    
    % e_ola
    e_ola = e_yoy - (e_yoy{-4} + e_yoy{-3} + e_yoy{-2} + e_yoy{-1})/4;
    
    % PREM_ola
    PREM_ola = PREM - (PREM{-4} + PREM{-3} + PREM{-2} + PREM{-1})/4;
    
    % pi_ola
    pi_ola  = pi_yoy - 4;
    
    % GDP_ola
    GDP_ola  = GDP_SM_yoy - (GDP_SM_yoy{-4} + GDP_SM_yoy{-3} + GDP_SM_yoy{-2} + GDP_SM_yoy{-1})/4;
    
    % IPriv_ola
    IPriv_ola  = IPriv_ratio - (IPriv_ratio{-4} + IPriv_ratio{-3} + IPriv_ratio{-2} + IPriv_ratio{-1})/4;
    
    % Model
    GDP_star_ola = a1_1*GDP_star_ola{-1} + u1;
    i_star_ola = a2_1*i_star_ola{-1} + u2;
    pi_star_ola = a3_1*pi_star_ola{-1} + u3;
    IPub_ola = a4_1*IPub_ola{-1} + u4;
    IngT_ola = a5_1*IngT_ola{-1} + u5;
    GFun_ola = a6_1*GFun_ola{-1} + u6;
    DPE_ola = a7_1*DPE_ola{-1} + u7;
    Rem_ola = a8_1*Rem_ola{-1} + u8;

    % DPI_ola
    DPI_ola = a9_1*DPI_ola{-1} + a9_2*DPE_ola{-1} + a9_3*(GFun_ola{-1} + IPub_ola{-1} - IngT_ola{-1}) + u9;

    AEN_ola = a10_1*AEN_ola{-1} + a10_2*DPE_ola{-1} + a10_3*(pi_star_ola{-1} + e_ola{-1} - pi_ola{-1}) + u10 + u7;
    AIN_ola = a11_1*AIN_ola{-1} + a11_2*DPI_ola{-1} + a11_3*i_ola{-1} + a11_4*pi_ola{-1} + u11 - u7;
    i_ola = a12_1*i_ola{-1} + a12_2*i_star_ola{-1} + a12_3*pi_ola{-1} + a12_4*GDP_ola{-1} + u12;
    e_ola = a13_1*e_ola{-1} + a13_2*(DPE_ola{-1} - AEN_ola{-1}) + a13_3*(i_ola{-1} - i_star_ola{-1} - PREM_ola{-1}) + u13;
    PREM_ola = a14_1*PREM_ola{-1} + a14_2*(DPI_ola{-1} - AIN_ola{-1} + DPE_ola{-1} - AEN_ola{-1}) + u14;
    pi_ola = a15_1*pi_ola{-1} + a15_2*GDP_ola{-1} + a15_3*pi_star_ola{-1} + a15_4*e_ola{-1} + a15_5*(AEN_ola{-1} + AIN_ola{-1}) + u15;
    GDP_ola = a16_1*GDP_ola{-1} + a16_2*GDP_star_ola{-1} + a16_3*Rem_ola{-1} + a16_4*(IPub_ola{-1} + IPriv_ola{-1}) + a16_5*(AEN_ola{-1} + AIN_ola{-1}) + u16;
    IPriv_ola = a17_1*IPriv_ola{-1} + a17_2*i_ola{-1} + a17_3*(DPI_ola{-1} - AIN_ola{-1})  + a17_4*PREM_ola{-1} + u17;
    
    % Other important variables
    % Amplified Monetary Base 
    % ratio
    AMB_ratio = AEN_ratio + AIN_ratio;
    % (ola)
    AMB_ola = AEN_ola + AIN_ola;
    
    % Real Exchange Rate
    % year on year change
    z = pi_star_yoy + e_yoy - pi_yoy;
    % (ola)
    z_ola = pi_star_ola + e_ola - pi_ola;
    
    % Consolidated external public debt
    % ratio
    DPEC_ratio = DPE_ratio - AEN_ratio;
    % (ola )
    DPEC_ola = DPE_ola - AEN_ola;

    % Consolidated domestic public debt
    % ratio
    DPIC_ratio = DPI_ratio - AIN_ratio;
    % (ola)
    DPIC_ola = DPI_ola - AIN_ola;
    
    % Consolidated total public debt
    % ratio
    DPTC_ratio = DPEC_ratio + DPIC_ratio;
    % (ola)
    DPTC_ola = DPEC_ola + DPIC_ola;
    
    % Total debt
    % ratio
    DPT_ratio = DPE_ratio + DPI_ratio;
    % (ola)
    DPT_ola = DPE_ola + DPI_ola;
    
    % Total invesmet 
    % ratio
    ITotal_ratio = IPub_ratio + IPriv_ratio;
    % (ola)
    ITotal_ola = IPub_ola + IPriv_ola;
    
    % deficit
    % ratio
    Def_ratio = IPub_ratio + Gfun_ratio - IngT_ratio;
    % ola
    Def_ola = IPub_ola + GFun_ola - IngT_ola;
    
    