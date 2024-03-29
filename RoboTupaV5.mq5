//+------------------------------------------------------------------+
//|                                                  RoboTupa_V4.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Tupã Trading"
#property link "http://www.paulista.tk/tupatrading"
#property version "0.0.1"

#include "ControleTrade.mqh"
#include "Renko.mqh"
#include "Filtros.mqh"

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+

input group "";
input group ">ID Robo ----------------------------------------------------"; //ID do robô (int)
input int Magic = 0;
input group "";
input group "";

input group ">Configurações de Trade ----------------------------------------------------";
input group "> >Horário de trabalho";
input int HoraDeInicio = 9;          //Hora de início
input int MinutoDeInicio = 1;        // Minuto de início
input int HoraDeEncerramento = 17;   //Hora de encerramento
input int MinutoDeEncerramento = 59; //Minuto de encerramento
input group "";

input group "> >Limites Financeiros";
input bool AtivaLimiteFinanceiro = false; //Ativar Limite Financeiro
input double MetaGanhoDia;                //Meta de Ganho por dia
input double MaximoPerdaDia;              //Máximo de perda por dia
input group "";
input group "> >Lotes";
input int Lote = 1; //Numero de Lotes
input group "";
input bool AtivarLoteDinamico = false;                               // Ativar Numero de Lotes Dinâmico
input group "Formula 1+(GanhoDia-TamanhoBox)*A" input double ALotes; //Fator A
input int LotesMin = 1;                                              //Mínimo de lotes
input int LotesMax = 5;                                              //Máximo de lotes
input group "";
input group "> > TakeProfit";
input double TakeProfitFixo;                                                                            //TakeProfit Fixo (0 S/ TP)
input group "> > > TakeProfit Baseado em bloco TP = (Bloco * A) + B" input bool AtivaTPemBloco = false; //Ativa TP em Blocos
input double tpA1;                                                                                      //A para Renko1
input double tpB1;                                                                                      //B para Renko1
input double tpA2;                                                                                      //A para Renko2
input double tpB2;                                                                                      //B para Renko2
input double tpA3;                                                                                      //A para Renko3
input double tpB3;                                                                                      //B para Renko3
input bool AtivaDividirTPPorEntradas = false;                                                           //Ativar Divisão do TP por Num de entradas na sequencia
input group "> > > TakeProfitATR (substitui o fixo)" input bool AtivarTakeProfitATR = false;            //Ativar TP Baseado em ATR
input int PeriodoTPAtr;                                                                                 // Periodo do ATR para o TakeProfit
input double MultTPAtr;                                                                                 //Multiplicador do ATR para TakeProfit
input group "";

input group "> > StopLoss";
input double StopLossFixo; //StopLoss Fixo (0 S/ SL)
input group "> > StopLoss Máximos do candle";
input bool AtivarStopinho;                                                                            //Ativar Stopinho
input group "> > > StopLoss Baseado em bloco SL = (Bloco * A) + B" input bool AtivaSLemBloco = false; //Ativa SL em Blocos
input double slA1;                                                                                    //A para Renko1
input double slB1;                                                                                    //B para Renko1
input double slA2;                                                                                    //A para Renko2
input double slB2;                                                                                    //B para Renko2
input double slA3;                                                                                    //A para Renko3
input double slB3;                                                                                    //B para Renko3
input bool AtivaDividirSLPorEntradas = false;                                                         //Ativar Divisão do SL por Num de entradas na sequencia
input group "> > > StopLossATR (substitui o fixo)" input bool AtivarStopLossATR = false;              //Ativar SL Baseado em ATR
input int PeriodoSLAtr;                                                                               // Periodo do ATR para o StopLoss
input double MultSLAtr;                                                                               //Multiplicador do ATR para StopLoss
input group "> > > Saída por cruzamento de RVI" input bool AtivarSaidaRvi = false;                    //Ativar SL Baseado em ATR
input double ToleranciaSaidaRvi;                                                                      //Tolerancia de cruzamento RVI
input group "> > > StopLoss Móvel" input bool AtivarSLmovel = false;                                  //Ativar StopLoss Móvel
input double InicioStopMovel;                                                                         //Valor Ativação do SL móvel
//input    double StopMovel; //Valor do StopLoss ao ser ativado
input double PassoStopMovel; //Passo de avanço SL móvel
input group "";
input group "";

input group ">Configurações Renko 1 ----------------------------------------------------";
input bool AtivarRenko1 = true; //Ativa Renko 1
input bool PlotRenko1 = false;  //Plotar renko 1 no gráfico do ativo
input group "";

input group "> >Tamanho do bloco1";
input BOX_MODE ModoTamanhoBox1 = PIPS;                              //Modo de calculo do tamanho do bloco
input group "> > >PIPS" input double TamanhoBoxPIPS1 = 100;         //Tamanho do Bloco Fixo PIPS
input group "> > >ATR direto e Inverso" input int PeriodoRenkoAtr1; //Periodo do ATR para calculo do Bloco
input double MultRenkoAtr1;                                         //Multiplicador para ATR Renko 1
input double TamanhoMinBloco1;                                      //Tamanho Mínimo do bloco
input double TamanhoMaxBloco1;                                      //Tamanho Máximo do bloco
input group "";

input group "> >Sinal de entrada";
input int NumBlocos1 = 3; //Numero de Blocos para entrar
input group "";
input group "> >Filtros de entrada Renko";
input group "> > >Filtro Soma de tempo dos blocos (Agressividade)" input bool AtivaAgressividade1 = false; //Ativar Filtro Agressividade
input ulong LimiteTempoBloco1;                                                                             //Limite da soma do tempo (ms)
input group "";

input group "> > >Filtro limite de entradas na mesma Sequencia" input bool AtivaLimiteEntradasSequencia1 = false; //Ativar filtro limite de entradas
input int LimiteEntradasSequencia1;                                                                               //Numero Máx. de entradas na mesma sequencia
input group "";

input group ">Configurações Renko 2 ----------------------------------------------------";
input bool AtivarRenko2 = false; //Ativa Renko 2
input bool PlotRenko2 = false;   //Plotar renko 2 no gráfico do ativo
input group "";

input group "> >Tamanho do bloco2";
input BOX_MODE ModoTamanhoBox2 = PIPS;                              //Modo de calculo do tamanho do bloco
input group "> > >PIPS" input double TamanhoBoxPIPS2 = 100;         //Tamanho do Bloco Fixo PIPS
input group "> > >ATR direto e Inverso" input int PeriodoRenkoAtr2; //Periodo do ATR para calculo do Bloco
input double MultRenkoAtr2;                                         //Multiplicador para ATR Renko 2
input double TamanhoMinBloco2;                                      //Tamanho Mínimo do bloco
input double TamanhoMaxBloco2;                                      //Tamanho Máximo do bloco
input group "";

input group "> >Sinal de entrada";
input int NumBlocos2 = 3; //Numero de Blocos para entrar
input group "";
input group "> >Filtros de entrada Renko";
input group "> > >Filtro Soma de tempo dos blocos (Agressividade)" input bool AtivaAgressividade2 = false; //Ativar Filtro Agressividade
input ulong LimiteTempoBloco2;                                                                             //Limite da soma do tempo (ms)
input group "";

input group "> > >Filtro limite de entradas na mesma Sequencia" input bool AtivaLimiteEntradasSequencia2 = false; //Ativar filtro limite de entradas
input int LimiteEntradasSequencia2;                                                                               //Numero Máx. de entradas na mesma sequencia
input group "";

input group ">Configurações Renko 3 ----------------------------------------------------";
input bool AtivarRenko3 = false; //Ativa Renko 3
input bool PlotRenko3 = false;   //Plotar renko 3 no gráfico do ativo
input group "";

input group "> >Tamanho do bloco3";
input BOX_MODE ModoTamanhoBox3 = PIPS;                              //Modo de calculo do tamanho do bloco
input group "> > >PIPS" input double TamanhoBoxPIPS3 = 100;         //Tamanho do Bloco Fixo PIPS
input group "> > >ATR direto e Inverso" input int PeriodoRenkoAtr3; //Periodo do ATR para calculo do Bloco
input double MultRenkoAtr3;                                         //Multiplicador para ATR Renko 3
input double TamanhoMinBloco3;                                      //Tamanho Mínimo do bloco
input double TamanhoMaxBloco3;                                      //Tamanho Máximo do bloco
input group "";

input group "> >Sinal de entrada";
input int NumBlocos3 = 3; //Numero de Blocos para entrar
input group "";
input group "> >Filtros de entrada Renko";
input group "> > >Filtro Soma de tempo dos blocos (Agressividade)" input bool AtivaAgressividade3 = false; //Ativar Filtro Agressividade
input ulong LimiteTempoBloco3;                                                                             //Limite da soma do tempo (ms)
input group "";

input group "> > >Filtro limite de entradas na mesma Sequencia" input bool AtivaLimiteEntradasSequencia3 = false; //Ativar filtro limite de entradas
input int LimiteEntradasSequencia3;                                                                               //Numero Máx. de entradas na mesma sequencia
input group "";

input group ">Outros Filtros de entrada ----------------------------------------------------";
input group "> >Filtro Hilo" input bool AtivaFiltroHilo; //Ativa Filtro Hilo
input bool PlotFiltroHilo;                               //Plotar Filtro Hilo
input uint PeriodoHilo;                                  //Período do HiLo
input ENUM_MA_METHOD ModoHilo;                           //Modo do HiLo
input double DistanciaHilo;                              //Distancia de Plotagem do HiLo
input group "";

input group "> >Filtro Distancia Média Móvel" input bool AtivaFiltroDistanciaMA; //Ativa Filtro Distancia MA
input bool PlotFiltroDistanciaMA;                                                //Plotar Filtro DistanciaMA
input int PeriodoCurtaMA;                                                        //Periodo MA Curta
input int ShiftCurtaMA;                                                          //Shift MA Longa
input ENUM_MA_METHOD ModoCurtaMA;                                                //Modo Ma Curta
input int PeriodoLongaMA;                                                        //Periodo MA Longa
input int ShiftLongaMA;                                                          //Shift MA Longa
input ENUM_MA_METHOD ModoLongaMA;                                                //Modo MA Longa
input double DistanciaMA;                                                        //Distanca entre MA para liberar
input group "";

input group "> >Filtro Suporte Resistencia" input bool AtivaFiltroSupRes; //Ativa Filtro Sup Res
input bool PlotFiltroSupRes;                                              //Plotar Filtro SupRes
input double TamanhoZonaSupRes;                                           //Tamanho da Zona de Sup e Res
input group "";

input group "> > Filtro taxa de acerto" input bool AtivaTaxaAcertos = false; //Ativar Filtro Taxa de acertos
input bool SeparaTaxaCompraVenda = false;                                    //Separar taxa de acerto compra/venda
input int NumeroBlocosParaConsiderarAcerto;                                  //Numero de blocos para considerar acerto
input double TaxaParaLiberar;                                                //Taxa de acertos Libera Entrada (%)
input double TaxaParaBloquear;                                               //Taxa de acertos Bloqueia Entrada (%)
input int NumeroDeSequenciasAnteriores;                                      //Num de Sequencias anteriores para analisar
input group "";

input group "> > Filtro RVI >= " input bool AtivaFiltroRvi = false; //Ativar Filtro RVI
input bool PlotRvi = false;                                         //Plotar Filtro RVI
input int PeriodoRvi = 1;                                           //Período RVI
input bool AguardaCandle = false;                                   //Aguardar fechamento do candle
input double NivelRviMin;                                           //Nível RVI Minimo
input double NivelSignalRviMin;                                     //Nivel Signal RVI Minimo
input double NivelRviMax;                                           //Nível RVI Maximo
input double NivelSignalRviMax;                                     //Nivel Signal RVI Maximo
input double MaxRampaRvi;                                           //Valor máximo de rampa RVI
input double MinRampaRvi;                                           //Valor mínimo de rampa RVI
input double DistanceRviSignal;                                     //Distancia Rvi Signal
input TIPO_RVI TipoRvi = OR;                                        //Tipo Filtro RVI
input group "";

input group "> > Filtro ATR" input bool AtivaFiltroAtr = false; //Ativar Filtro ATR
input bool PlotAtr = false;                                     //Plotar Filtro ATR
input int PeriodoAtr = 5;                                       //Período ATR
input group "";

input group "> > Filtro Taxa Crescimento Vol" input bool AtivaFiltroVolRate = false; //Ativar Filtro Taxa Volume
input bool PlotVolRate = false;                                                      //Plotar Filtro Taxa Volume
input double VolMin;                                                                 //Volume Mínimo para entrar
input TIPO_VOL_RATE TipoVolRate = MANUAL;                                            //Tipo manual ou automático
input ENUM_APPLIED_VOLUME InpVolumeType;                                             //Tipo Volume
input double VolPorCandle = 10000;                                                   //Volume por Candle (MANUAL)
input int PeriodoMediaVol = 30;                                                      //Período média Vol (AUTOMATICO)
input ENUM_MA_METHOD ma_method = MODE_SMA;                                           //Tipo Média (AUTOMATICO)
input double TaxaRompimento = 2;                                                     //Taxa de rompimento volume (AUTOMATICO)
input group "";

input group "> > Filtro DELTA" input MAIN_INDICATOR MainIndicator = DELTA_;
input datetime inpHistoryDate = 0;    //Inicio do historico de ticks
input bool AtivaFiltroDelta = false;  //Ativar Filtro DELTA
input bool PlotDelta = false;         //Plotar Filtro DELTA
input int TargetValueBuySellRate = 1; //Valor alvo de fator Compra/Venda
input double SamplingTime = 50;       //Tempo de aquisição (ms)
input int MeanPeriod = 50;            //Periodo da média de atenuação
input bool ShowRealVolume = false;
input double MultDelta = 1; //Fator de Delta acima da média
input group "";

ControleTrade controletrade;
Renko renko1;
Renko renko2;
Renko renko3;
Filtros FiltroHilo;
Filtros FiltroMADistance;
Filtros FiltroSupRes;
Filtros FiltroRvi;
Filtros FiltroAtr;
Filtros FiltroVolRate;
Filtros FiltroDelta;

int IdRenkoPosicao = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Comprado = controletrade.Comprado();
bool Vendido = controletrade.Vendido();

double TP_ = 0;
double SL_ = 0;

int lotes;

bool PosicaoCorrigida = false;

int StopsWatchDog = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---

   controletrade.ConfiguraTrade(HoraDeInicio, MinutoDeInicio, HoraDeEncerramento, MinutoDeEncerramento, AtivaLimiteFinanceiro, MetaGanhoDia, MaximoPerdaDia, Magic, 0, Lote, TakeProfitFixo, StopLossFixo, AtivarTakeProfitATR, PeriodoTPAtr, MultTPAtr, AtivarStopLossATR, PeriodoSLAtr, MultSLAtr, InicioStopMovel, PassoStopMovel);
   controletrade.Start();

   renko1.ConfiguraRenko(ModoTamanhoBox1, TamanhoBoxPIPS1, PeriodoRenkoAtr1, MultRenkoAtr1, CLOSE, TamanhoMinBloco1, TamanhoMaxBloco1, NumBlocos1, AtivaAgressividade1, LimiteTempoBloco1, AtivaLimiteEntradasSequencia1, LimiteEntradasSequencia1, NumeroBlocosParaConsiderarAcerto, NumeroDeSequenciasAnteriores);
   if (AtivarRenko1)
      renko1.Start();

   renko2.ConfiguraRenko(ModoTamanhoBox2, TamanhoBoxPIPS2, PeriodoRenkoAtr2, MultRenkoAtr2, CLOSE, TamanhoMinBloco2, TamanhoMaxBloco2, NumBlocos2, AtivaAgressividade2, LimiteTempoBloco2, AtivaLimiteEntradasSequencia2, LimiteEntradasSequencia2, NumeroBlocosParaConsiderarAcerto, NumeroDeSequenciasAnteriores);
   if (AtivarRenko2)
      renko2.Start();

   renko3.ConfiguraRenko(ModoTamanhoBox3, TamanhoBoxPIPS3, PeriodoRenkoAtr3, MultRenkoAtr3, CLOSE, TamanhoMinBloco3, TamanhoMaxBloco3, NumBlocos3, AtivaAgressividade3, LimiteTempoBloco3, AtivaLimiteEntradasSequencia3, LimiteEntradasSequencia3, NumeroBlocosParaConsiderarAcerto, NumeroDeSequenciasAnteriores);
   if (AtivarRenko3)
      renko3.Start();

   FiltroHilo.Tipo = HILO;
   FiltroHilo.PeriodoHiLo = PeriodoHilo;
   FiltroHilo.ModoHiLo = ModoHilo;
   FiltroHilo.DistanciaHiLo = DistanciaHilo;
   if (AtivaFiltroHilo)
      FiltroHilo.Start();

   FiltroMADistance.Tipo = MA_DISTANCE;
   FiltroMADistance.PeriodoCurtaMA = PeriodoCurtaMA;
   FiltroMADistance.ShiftCurtaMA = ShiftCurtaMA;
   FiltroMADistance.ModoCurtaMA = ModoCurtaMA;
   FiltroMADistance.PeriodoLongaMA = PeriodoLongaMA;
   FiltroMADistance.ShiftLongaMA = ShiftLongaMA;
   FiltroMADistance.ModoLongaMA = ModoLongaMA;
   FiltroMADistance.DistanciaMA = DistanciaMA;
   if (AtivaFiltroDistanciaMA)
      FiltroMADistance.Start();

   FiltroSupRes.Tipo = SUP_RES_ZONE;
   FiltroSupRes.TamanhoZonaSupRes = TamanhoZonaSupRes;
   if (AtivaFiltroSupRes)
      FiltroSupRes.Start();

   FiltroRvi.Tipo = RVI;
   FiltroRvi.AguardaCandle = AguardaCandle;
   FiltroRvi.PeriodoRvi = PeriodoRvi;
   FiltroRvi.RviValueMin = NivelRviMin;
   FiltroRvi.SignalRviValueMin = NivelSignalRviMin;
   FiltroRvi.RviValueMax = NivelRviMax;
   FiltroRvi.SignalRviValueMax = NivelSignalRviMax;
   FiltroRvi.MinRampaRvi = MinRampaRvi;
   FiltroRvi.MaxRampaRvi = MaxRampaRvi;
   FiltroRvi.TipoFiltroRvi = TipoRvi;
   FiltroRvi.DistanciaRviSignal = DistanceRviSignal;
   if (AtivaFiltroRvi || AtivarSaidaRvi)
      FiltroRvi.Start();

   FiltroAtr.Tipo = ATR;
   FiltroAtr.PeriodoAtr = PeriodoAtr;
   if (AtivaFiltroAtr)
      FiltroAtr.Start();

   FiltroVolRate.Tipo = VOL_RATE;
   FiltroVolRate.VolMin = VolMin;
   FiltroVolRate.TipoVolRate = TipoVolRate;
   FiltroVolRate.VolPorCandle = VolPorCandle;
   FiltroVolRate.InpVolumeType = InpVolumeType;
   FiltroVolRate.PeriodoMediaVol = PeriodoMediaVol;
   FiltroVolRate.ma_method = ma_method;
   FiltroVolRate.TaxaRompimento = TaxaRompimento;
   if (AtivaFiltroVolRate)
      FiltroVolRate.Start();

   FiltroDelta.Tipo = DELTA;
   FiltroDelta.MainIndicator = MainIndicator;
   FiltroDelta.inpHistoryDate = inpHistoryDate;
   FiltroDelta.TargetValueBuySellRate = TargetValueBuySellRate;
   FiltroDelta.ShowRealVolume = ShowRealVolume;
   FiltroDelta.MultDelta = MultDelta;
   if (AtivaFiltroDelta)
      FiltroDelta.Start();

   if (AtivarRenko1 && PlotRenko1)
      ChartIndicatorAdd(ChartID(), 1, renko1.RenkoHandle);

   if (AtivarRenko2 && PlotRenko2)
      ChartIndicatorAdd(ChartID(), 2, renko2.RenkoHandle);

   if (AtivarRenko3 && PlotRenko3)
      ChartIndicatorAdd(ChartID(), 3, renko3.RenkoHandle);

   if (AtivaFiltroHilo && PlotFiltroHilo)
      ChartIndicatorAdd(ChartID(), 0, FiltroHilo.IndicadorHandle1);

   if (AtivaFiltroDistanciaMA && PlotFiltroDistanciaMA)
   {
      ChartIndicatorAdd(ChartID(), 0, FiltroMADistance.IndicadorHandle1);
      ChartIndicatorAdd(ChartID(), 0, FiltroMADistance.IndicadorHandle2);
   }

   if (AtivaFiltroSupRes && PlotFiltroSupRes)
      ChartIndicatorAdd(ChartID(), 0, FiltroSupRes.IndicadorHandle1);

   if (AtivaFiltroRvi && PlotRvi)
      ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL), FiltroRvi.IndicadorHandle1);

   if (AtivaFiltroAtr && PlotAtr)
      ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL), FiltroAtr.IndicadorHandle1);

   if (AtivaFiltroVolRate && PlotVolRate)
      if (FiltroVolRate.TipoVolRate == AUTOMATICO)
      {
         //int total = ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL,0);
         ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL), FiltroVolRate.IndicadorHandle1);
         //total = ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL,0);
         ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL) - 1, FiltroVolRate.IndicadorHandle2);
      }
      else
         ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL), FiltroVolRate.IndicadorHandle1);

   if (AtivaFiltroDelta && PlotDelta)
   {
      ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL), FiltroDelta.IndicadorHandle1);
      ChartIndicatorAdd(ChartID(), (int)ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL) - 1, FiltroDelta.IndicadorHandle2);
   }
   //---
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---
   //ENCERRA TODAS AS POSIÇÕES
   controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

   //REMOVE TODOS INDICADORES
   long total = ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL);
   for (int h = 0; h < total; h++)
      for (int i = 0; i < ChartIndicatorsTotal(0, h); i++)
      {
         if (!ChartIndicatorDelete(0, h, ChartIndicatorName(0, h, i)))
         {
            Print("error indicator delete, rc=", GetLastError());
         }
         else
         {
            i--;
         }
      }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //---

   Comprado = controletrade.Comprado();
   Vendido = controletrade.Vendido();

   //Sinais do Renko   (1 PARA SINAL DE COMPRA. 2 PARA SINAL DE VENDA)
   int Sinal1 = 0;
   int Sinal2 = 0;
   int Sinal3 = 0;

   if (AtivarRenko1)
   {
      Sinal1 = renko1.SinalCompraOuVenda();
      renko1.LiberadoPorTaxaCompra(SeparaTaxaCompraVenda, TaxaParaBloquear, TaxaParaLiberar);
      renko1.LiberadoPorTaxaVenda(SeparaTaxaCompraVenda, TaxaParaBloquear, TaxaParaLiberar);
   }
   if (AtivarRenko2)
   {
      Sinal2 = renko2.SinalCompraOuVenda();
      renko2.LiberadoPorTaxaCompra(SeparaTaxaCompraVenda, TaxaParaBloquear, TaxaParaLiberar);
      renko2.LiberadoPorTaxaVenda(SeparaTaxaCompraVenda, TaxaParaBloquear, TaxaParaLiberar);
   }
   if (AtivarRenko3)
   {
      Sinal3 = renko3.SinalCompraOuVenda();
      renko3.LiberadoPorTaxaCompra(SeparaTaxaCompraVenda, TaxaParaBloquear, TaxaParaLiberar);
      renko3.LiberadoPorTaxaVenda(SeparaTaxaCompraVenda, TaxaParaBloquear, TaxaParaLiberar);
   }

   if (!Comprado && !Vendido)
   {

      IdRenkoPosicao = 0;
      PosicaoCorrigida = false;
      StopsWatchDog = 0;

      //VERIFICAÇÃO FILTROS GERAIS
      if ((Sinal1 == 1 || Sinal2 == 1 || Sinal3 == 1) && ((AtivaFiltroHilo && !FiltroHilo.LiberaCompra()) || (AtivaFiltroDistanciaMA && !FiltroMADistance.LiberaCompra()) || (AtivaFiltroSupRes && !FiltroSupRes.LiberaCompra()) || (AtivaFiltroRvi && !FiltroRvi.LiberaCompra()) || (AtivaFiltroVolRate && !FiltroVolRate.LiberaCompra()) || (AtivaFiltroDelta && !FiltroDelta.LiberaCompra())))
         Sinal1 = Sinal2 = Sinal3 = 0;
      if ((Sinal1 == 2 || Sinal2 == 2 || Sinal3 == 2) && ((AtivaFiltroHilo && !FiltroHilo.LiberaVenda()) || (AtivaFiltroDistanciaMA && !FiltroMADistance.LiberaVenda()) || (AtivaFiltroSupRes && !FiltroSupRes.LiberaVenda()) || (AtivaFiltroRvi && !FiltroRvi.LiberaVenda()) || (AtivaFiltroVolRate && !FiltroVolRate.LiberaVenda()) || (AtivaFiltroDelta && !FiltroDelta.LiberaVenda())))
         Sinal1 = Sinal2 = Sinal3 = 0;

      //VERIFICAÇÃO FILTRO TAXA E PRIORIZAÇÃO
      if (AtivaTaxaAcertos)
      {

         if (Sinal1 == 1)
         {
            if (!renko1.LiberaPorTaxaCompra)
               Sinal1 = 0;
            else
               Sinal3 = Sinal2 = 0;
         }
         if (Sinal1 == 2)
         {
            if (!renko1.LiberaPorTaxaVenda)
               Sinal1 = 0;
            else
               Sinal3 = Sinal2 = 0;
         }

         if (Sinal2 == 1)
         {
            if (renko1.LiberaPorTaxaCompra || !renko2.LiberaPorTaxaCompra)
               Sinal2 = 0;
            else
               Sinal3 = 0;
         }
         if (Sinal2 == 2)
         {
            if (renko1.LiberaPorTaxaVenda || !renko2.LiberaPorTaxaVenda)
               Sinal2 = 0;
            else
               Sinal3 = 0;
         }
         if (Sinal3 == 1)
         {
            if (renko1.LiberaPorTaxaCompra || renko2.LiberaPorTaxaCompra || !renko3.LiberaPorTaxaCompra)
               Sinal3 = 0;
         }
         if (Sinal3 == 2)
         {
            if (renko1.LiberaPorTaxaVenda || renko2.LiberaPorTaxaVenda || !renko3.LiberaPorTaxaVenda)
               Sinal3 = 0;
         }
      }

      //VERIFICA QUAL RENKO E AJUSTA TP E SL
      if (Sinal3 != 0)
      {
         double box = renko3.RetornaTamanhoBlocoAtual();

         if (AtivaTPemBloco)
            TP_ = controletrade.NormalizePrice(box * tpA3 + tpB3);
         else
            TP_ = controletrade.RetornaTakeProfit();

         if (AtivaSLemBloco)
            SL_ = controletrade.NormalizePrice(box * slA3 + slB3);
         else
            SL_ = controletrade.RetornaStopLoss();

         if (AtivarLoteDinamico)
         {
            lotes = (int)(1 + ((controletrade.GanhoMaxDoDia - box) * ALotes));

            if (lotes < LotesMin)
               lotes = LotesMin;

            if (lotes > LotesMax)
               lotes = LotesMax;
         }
         else
            lotes = Lote;
      }

      if (Sinal2 != 0)
      {
         double box = renko2.RetornaTamanhoBlocoAtual();

         if (AtivaTPemBloco)
            TP_ = controletrade.NormalizePrice(box * tpA2 + tpB2);
         else
            TP_ = controletrade.RetornaTakeProfit();

         if (AtivaSLemBloco)
            SL_ = controletrade.NormalizePrice(box * slA2 + slB2);
         else
            SL_ = controletrade.RetornaStopLoss();

         if (AtivarLoteDinamico)
         {
            lotes = (int)(1 + ((controletrade.GanhoMaxDoDia - box) * ALotes));

            if (lotes < LotesMin)
               lotes = LotesMin;

            if (lotes > LotesMax)
               lotes = LotesMax;
         }
         else
            lotes = Lote;

         Sinal3 = 0;
      }

      if (Sinal1 != 0)
      {
         double box = renko1.RetornaTamanhoBlocoAtual();

         if (AtivaTPemBloco)
            TP_ = controletrade.NormalizePrice(box * tpA1 + tpB1);
         else
            TP_ = controletrade.RetornaTakeProfit();

         if (AtivaSLemBloco)
            SL_ = controletrade.NormalizePrice(box * slA1 + slB1);
         else
            SL_ = controletrade.RetornaStopLoss();

         if (AtivarLoteDinamico)
         {
            lotes = (int)(1 + ((controletrade.GanhoMaxDoDia - box) * ALotes));

            if (lotes < LotesMin)
               lotes = LotesMin;

            if (lotes > LotesMax)
               lotes = LotesMax;
         }
         else
            lotes = Lote;

         Sinal3 = Sinal2 = 0;
      }

      //VERIFICAÇÃO FILTRO ATR
      if (Sinal1 == 1)
      {
         if (AtivaFiltroAtr && !FiltroAtr.LiberaCompra(TP_))
            Sinal1 = 0;
      }
      if (Sinal2 == 1)
      {
         if (AtivaFiltroAtr && !FiltroAtr.LiberaCompra(TP_))
            Sinal2 = 0;
      }
      if (Sinal3 == 1)
      {
         if (AtivaFiltroAtr && !FiltroAtr.LiberaCompra(TP_))
            Sinal3 = 0;
      }

      if (Sinal1 == 2)
      {
         if (AtivaFiltroAtr && !FiltroAtr.LiberaVenda(TP_))
            Sinal1 = 0;
      }
      if (Sinal2 == 2)
      {
         if (AtivaFiltroAtr && !FiltroAtr.LiberaVenda(TP_))
            Sinal2 = 0;
      }
      if (Sinal3 == 2)
      {
         if (AtivaFiltroAtr && !FiltroAtr.LiberaVenda(TP_))
            Sinal3 = 0;
      }

      if (Sinal1 == 1 || Sinal2 == 1 || Sinal3 == 1)
      {
         if (Sinal1 != 0)
         {
            renko1.EntradasNaSequencia = renko1.EntradasNaSequencia + 1;
            if (AtivaDividirTPPorEntradas)
               TP_ = controletrade.NormalizePrice((double)TP_ / (double)renko1.EntradasNaSequencia);

            if (AtivaDividirSLPorEntradas)
               SL_ = controletrade.NormalizePrice((double)SL_ / (double)renko1.EntradasNaSequencia);

            IdRenkoPosicao = 1;
            Print("COMPROU por RENKO 1");
         }
         else if (Sinal2 != 0)
         {
            renko2.EntradasNaSequencia = renko2.EntradasNaSequencia + 1;
            if (AtivaDividirTPPorEntradas)
               TP_ = controletrade.NormalizePrice((double)TP_ / (double)renko2.EntradasNaSequencia);

            if (AtivaDividirSLPorEntradas)
               SL_ = controletrade.NormalizePrice((double)SL_ / (double)renko2.EntradasNaSequencia);

            IdRenkoPosicao = 2;
            Print("COMPROU por RENKO 2");
         }
         else
         {
            renko3.EntradasNaSequencia = renko3.EntradasNaSequencia + 1;
            if (AtivaDividirTPPorEntradas)
               TP_ = controletrade.NormalizePrice((double)TP_ / (double)renko3.EntradasNaSequencia);

            if (AtivaDividirSLPorEntradas)
               SL_ = controletrade.NormalizePrice((double)SL_ / (double)renko3.EntradasNaSequencia);

            IdRenkoPosicao = 3;
            Print("COMPROU por RENKO 3");
         }

         //ao chegar nesse ponto SL_ E TP_ já estão normalizados para o ativo
         controletrade.Compra(controletrade.Slippage, lotes, SL_, TP_, controletrade.Magic);
         //PosicaoCorrigida = false;
      }
      if (Sinal1 == 2 || Sinal2 == 2 || Sinal3 == 2)
      {
         if (Sinal1 != 0)
         {
            renko1.EntradasNaSequencia = renko1.EntradasNaSequencia + 1;
            if (AtivaDividirTPPorEntradas)
               TP_ = controletrade.NormalizePrice((double)TP_ / (double)renko1.EntradasNaSequencia);

            if (AtivaDividirSLPorEntradas)
               SL_ = controletrade.NormalizePrice((double)SL_ / (double)renko1.EntradasNaSequencia);

            IdRenkoPosicao = 1;
            Print("VENDEU por RENKO 1");
         }
         else if (Sinal2 != 0)
         {
            renko2.EntradasNaSequencia = renko2.EntradasNaSequencia + 1;
            if (AtivaDividirTPPorEntradas)
               TP_ = controletrade.NormalizePrice((double)TP_ / (double)renko2.EntradasNaSequencia);

            if (AtivaDividirSLPorEntradas)
               SL_ = controletrade.NormalizePrice((double)SL_ / (double)renko2.EntradasNaSequencia);

            IdRenkoPosicao = 2;
            Print("VENDEU por RENKO 2");
         }
         else
         {
            renko3.EntradasNaSequencia = renko3.EntradasNaSequencia + 1;
            if (AtivaDividirTPPorEntradas)
               TP_ = controletrade.NormalizePrice((double)TP_ / (double)renko3.EntradasNaSequencia);

            if (AtivaDividirSLPorEntradas)
               SL_ = controletrade.NormalizePrice((double)SL_ / (double)renko3.EntradasNaSequencia);

            IdRenkoPosicao = 3;
            Print("VENDEU por RENKO 3");
         }

         //ao chegar nesse ponto SL_ E TP_ já estão normalizados para o ativo
         controletrade.Venda(controletrade.Slippage, lotes, SL_, TP_, controletrade.Magic);
         //PosicaoCorrigida = false;
      }
   }

   if (Comprado)
   {

      if (!PosicaoCorrigida)
      {
         PosicaoCorrigida = controletrade.CorrigirPosicao(controletrade.Magic, controletrade.Slippage, SL_ > 0 ? SL_ : 0, TP_ > 0 ? TP_ : 0);
         StopsWatchDog = StopsWatchDog + 1;
      }

      if (StopsWatchDog >= 3)
         controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

      if (!controletrade.ActualyOnWorkPeriod())
         controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

      if (AtivarSLmovel)
         controletrade.AjustaStopMovel(controletrade.InicioStopMovel, SL_, controletrade.PassoStopMovel);

      if (AtivarSaidaRvi && FiltroRvi.VerificaSaidaDeCompraRvi(ToleranciaSaidaRvi))
         controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

      if (AtivarStopinho)
         switch (IdRenkoPosicao)
         {
         case 1:
            if (renko1.RetornaUltimaSequencia() == -1)
               controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);
            break;
         case 2:
            if (renko2.RetornaUltimaSequencia() == -1)
               controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);
            break;
         case 3:
            if (renko3.RetornaUltimaSequencia() == -1)
               controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);
            break;
         }
   }
   else if (Vendido)
   {
      if (!PosicaoCorrigida)
      {
         PosicaoCorrigida = controletrade.CorrigirPosicao(controletrade.Magic, controletrade.Slippage, SL_ > 0 ? SL_ : 0, TP_ > 0 ? TP_ : 0);
         StopsWatchDog = StopsWatchDog + 1;
      }

      if (StopsWatchDog >= 3)
         controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

      if (!controletrade.ActualyOnWorkPeriod())
         controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

      if (AtivarSLmovel)
         controletrade.AjustaStopMovel(controletrade.InicioStopMovel, SL_, controletrade.PassoStopMovel);

      if (AtivarSaidaRvi && FiltroRvi.VerificaSaidaDeVendaRvi(ToleranciaSaidaRvi))
         controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);

      if (AtivarStopinho)
         switch (IdRenkoPosicao)
         {
         case 1:
            if (renko1.RetornaUltimaSequencia() == 1)
               controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);
            break;
         case 2:
            if (renko2.RetornaUltimaSequencia() == 1)
               controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);
            break;
         case 3:
            if (renko3.RetornaUltimaSequencia() == 1)
               controletrade.EncerraTodasPosicoes(controletrade.Magic, controletrade.Slippage);
            break;
         }
   }
}
//+------------------------------------------------------------------+
