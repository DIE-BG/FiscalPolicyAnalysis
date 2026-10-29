!measurement_variables
m_GDP_star,
m_i_star,
m_pi_star,
m_IPub,
m_IngT,
m_GFun,
m_DPE,
m_Rem,
m_DPI,
m_AEN,
m_AIN,
m_i,
m_e,
m_PREM,
m_pi,
m_GDP,
m_IPriv

!measurement_equations
m_GDP_star = GDP_star;
m_i_star = i_star;
m_pi_star = pi_star;
m_IPub = IPub;
m_IngT = IngT;
m_GFun = GFun;
m_DPE = DPE;
m_Rem = Rem;
m_DPI = DPI;
m_AEN = AEN;
m_AIN = AIN;
m_i = i;
m_e = e;
m_PREM = PREM;
m_pi = pi;
m_GDP = GDP;
m_IPriv = IPriv;


%% 1. Variables
!transition-variables
'Crecimiento económico externo (ola)'                 GDP_star,
'Tasa de interés externa (ola)'                       i_star,
'Inflación externa (ola)'                             pi_star,
'Inversió pública (ola)'                              IPub,
'Ingresos totales (ola)'                              IngT,
'Gasto de funcionamiento (ola)'                       GFun,
'Deuda pública externa (ola)'                         DPE,
'Remesas (ola)'                                       Rem,
'Deuda pública interna (ola)'                         DPI,
'Activos externos netos (ola)'                        AEN,
'Activos internos netos (ola)'                        AIN,
'Tasa de interés líder de política monetaria (ola)'   i,
'Depreciación monetaria (ola)'                        e,
'Prima por riesgo país (ola)'                         PREM,
'Inflación domésticoa (ola)'                          pi,
'Crecimiento económico (ola)'                         GDP,
'Inversió privada (ola)'                              IPriv,
'Base monetaria ampliada (ola)'                       AMB,
'Tipo de cambio real (ola)'                           R,
'Deuda pública externa consolidada (ola)'             DPEC,
'Deuda pública interna consolidada (ola)'             DPIC,
'Deuda pública total consolidada (ola)'               DPTC,
'Inversion total'                                     ITotal


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
'Residou de la deuda publica interna'                 u9,
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
    a10_4,
    a10_5,
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
    GDP_star = a1_1*GDP_star{-1} + u1;
    i_star = a2_1*i_star{-1} + u2;
    pi_star = a3_1*pi_star{-1} + u3;
    IPub = a4_1*IPub{-1} + u4;
    IngT = a5_1*IngT{-1} + u5;
    GFun = a6_1*GFun{-1} + u6;
    DPE = a7_1*DPE{-1} + u7;
    Rem = a8_1*Rem{-1} + u8;

    % DPI
    DPI = a9_1*DPI{-1} + a9_2*DPE{-1} + a9_3*(GFun{-1} + IPub{-1} - IngT{-1}) + u9;

    AEN = a10_1*AEN{-1} + a10_2*DPE{-1} + a10_3*pi_star{-1} + a10_4*e{-1} + a10_5*pi{-1} + u10;
    AIN = a11_1*AIN{-1} + a11_2*DPI{-1} + a11_3*i{-1} + a11_4*pi{-1} + u11;
    i = a12_1*i{-1} + a12_2*i_star{-1} + a12_3*pi{-1} + a12_4*GDP{-1} + u12;
    e = a13_1*e{-1} + a13_2*(DPE{-1} - AEN{-1}) + a13_3*(i{-1} - i_star{-1} - PREM{-1}) + u13;
    PREM = a14_1*PREM{-1} + a14_2*(DPI{-1} - AIN{-1} + DPE{-1} - AEN{-1}) + u14;
    pi = a15_1*pi{-1} + a15_2*GDP{-1} + a15_3*pi_star{-1} + a15_4*e{-1} + a15_5*(AEN{-1} + AIN{-1}) + u15;
    GDP = a16_1*GDP{-1} + a16_2*GDP_star{-1} + a16_3*Rem{-1} + a16_4*(IPub{-1} + IPriv{-1}) + a16_5*(AEN{-1} + AIN{-1}) + u16;
    IPriv = a17_1*IPriv{-1} + a17_2*i{-1} + a17_3*(DPI{-1} - AIN{-1})  + a17_4*PREM{-1} + u17;
    
    % Amplified Monetary Base
    AMB = AEN + AIN;
    
    % Real Exchange Rate
    R = pi_star + e - pi;
    
    % Consolidated external public debt
    DPEC = DPE - AEN;

    % Consolidated domestic public debt
    DPIC = DPI - AIN;
    
    % Consolidated total public debt
    DPTC = DPEC + DPIC;
    
    % Total invesmet
    ITotal = IPub + IPriv;
    