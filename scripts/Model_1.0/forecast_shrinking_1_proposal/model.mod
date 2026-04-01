%% 1. Variables
!transition-variables
'Crecimiento económico externo (ola)'                 y1,
'Tasa de interés externa (ola)'                       y2,
'Inflación externa (ola)'                             y3,
'Inversió pública (ola)'                              y4,
'Ingresos totales (ola)'                              y5,
'Gasto de funcionamiento (ola)'                       y6,
'Deuda pública externa (ola)'                         y7,
'Remesas (ola)'                                       y8,
'Deuda pública interna (ola)'                         y9,
'Activos externos netos (ola)'                        y10,
'Activos internos netos (ola)'                        y11,
'Tasa de interés líder de política monetaria (ola)'   y12,
'Depreciación monetaria (ola)'                        y13,
'Prima por riesgo país (ola)'                         y14,
'Inflación domésticoa (ola)'                          y15,
'Crecimiento económico (ola)'                         y16,
'Inversió privada (ola)'                              y17,
'Residuo (no libre) de la deuda pública interna'      u9

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
    y1 = a1_1*y1{-1} + u1;
    y2 = a2_1*y2{-1} + u2;
    y3 = a3_1*y3{-1} + u3;
    y4 = a4_1*y4{-1} + u4;
    y5 = a5_1*y5{-1} + u5;
    y6 = a6_1*y6{-1} + u6;
    y7 = a7_1*y7{-1} + u7;
    y8 = a8_1*y8{-1} + u8;

    % Deuda publica interna
    y9 = a9_1*y9{-1} + a9_2*y7{-1} + a9_3*(y6{-1} + y4{-1} - y5{-1}) + u9;

    y10 = a10_1*y10{-1} + a10_2*y7{-1} + a10_3*y3{-1} + a10_4*y13{-1} + a10_5*y15{-1} + u10;
    y11 = a11_1*y11{-1} + a11_2*y9{-1} + a11_3*y12{-1} + a11_4*y15{-1} + u11;
    y12 = a12_1*y12{-1} + a12_2*y2{-1} + a12_3*y15{-1} + a12_4*y16{-1} + u12;
    y13 = a13_1*y13{-1} + a13_2*(y7{-1} - y10{-1}) + a13_3*(y12{-1} - y2{-1} - y14{-1}) + u13;
    y14 = a14_1*y14{-1} + a14_2*(y9{-1} - y11{-1} + y7{-1} - y10{-1}) + u14;
    y15 = a15_1*y15{-1} + a15_2*y16{-1} + a15_3*y3{-1} + a15_4*y13{-1} + a15_5*(y10{-1} + y11{-1}) + u15;
    y16 = a16_1*y16{-1} + a16_2*y1{-1} + a16_3*y8{-1} + a16_4*(y4{-1} + y17{-1}) + a16_5*(y10{-1} + y11{-1}) + u16;
    y17 = a17_1*y17{-1} + a17_2*y12{-1} + a17_3*(y9{-1} - y11{-1})  + a17_4*y14{-1} + u17;

    % Residuo de la inversion publica interna
    u9 = (1-a9_1)*y9{-1} + (1 - a7_1 - a9_2)*y7{-1} ...
         + (a6_1 - a9_3)*y6{-1} + (a4_1 - a9_3)*y4{-1} - (a5_1 + a9_3)*y5{-1} ...
         + u4 + u6 - u5 - u7;

%%%%%%%% Variables Observables %%%%%%%%%%%%%%%%
!measurement_variables
m_y1,
m_y2,
m_y3,
m_y4,
m_y5,
m_y6,
m_y7,
m_y8,
m_y9,
m_y10,
m_y11,
m_y12,
m_y13,
m_y14,
m_y15,
m_y16,
m_y17,

!measurement_equations
m_y1 = y1;
m_y2 = y2;
m_y3 = y3;
m_y4 = y4;
m_y5 = y5;
m_y6 = y6;
m_y7 = y7;
m_y8 = y8;
m_y9 = y9;
m_y10 = y10;
m_y11 = y11;
m_y12 = y12;
m_y13 = y13;
m_y14 = y14;
m_y15 = y15;
m_y16 = y16;
m_y17 = y17;