//+------------------------------------------------------------------+
//|                                                      RoboTupa_V4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

enum BOX_MODE
{
   PIPS,
   ATR_DIRETO,
   ATR_INVERSO
};
enum RENKO_MODE
{
   CLOSE,
   HIGH_LOW
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Renko
{
public:
   // Atributos públicos

   BOX_MODE ModoTamanhoBox;
   double TamanhoBoxFixo;
   int PeriodoAtr;
   double MultiplicadorAtr;
   RENKO_MODE ModoRenko;
   double TamanhoMinBox;
   double TamanhoMaxBox;
   bool PlotarTempoBloco;
   int EntradasNaSequencia;

   bool LiberaPorTaxaCompra;
   bool LiberaPorTaxaVenda;

   int RenkoHandle;

   // <Config Liberação>
   int BlocosEntrada;

   bool AtivaLimiteSomaTempoBloco;
   ulong LimiteSomaTempoBloco;

   bool AtivaLimiteEntradasNaSequencia;
   int LimiteEntradaNaSequencia;

   int NumeroBlocosParaConsiderarAcerto;

   int NumeroDeSequenciasAnteriores;

   // </Config Liberação>

   //Métodos públicos
   Renko()
   {
      ModoTamanhoBox = PIPS;
      TamanhoBoxFixo = 50;
      ModoRenko = CLOSE;
      PlotarTempoBloco = false;
      BlocosEntrada = 0;
      TamanhoMinBox = 20;
      TamanhoMaxBox = 100;

      AtivaLimiteSomaTempoBloco = false;

      RenkoHandle = INVALID_HANDLE;

      NumeroDeSequenciasAnteriores = 1;

      LiberaPorTaxaCompra = false;
      LiberaPorTaxaVenda = false;

      ArraySetAsSeries(RenkoColor, true);
      ArraySetAsSeries(RenkoBlockTime, true);
      ArraySetAsSeries(RenkoSequence, true);
      ArraySetAsSeries(RenkoTaxaAcertoGeral, true);
      ArraySetAsSeries(RenkoTaxaAcertoCompra, true);
      ArraySetAsSeries(RenkoTaxaAcertoVenda, true);
      ArraySetAsSeries(RenkoTamanhoBox, true);

      UltimaSequencia = 0;
   }

   ~Renko()
   {
   }

   void ConfiguraRenko(

       BOX_MODE ModoTamanhoBox_cfg,
       double TamanhoBoxFixo_cfg,
       int PeriodoAtr_cfg,
       double MultiplicadorAtr_cfg,
       RENKO_MODE ModoRenko_cfg,
       double TamanhoMinBox_cfg,
       double TamanhoMaxBox_cfg,

       int BlocosEntrada_cfg,

       bool AtivaLimiteSomaTempoBloco_cfg,
       ulong LimiteSomaTempoBloco_cfg,

       bool AtivaLimiteEntradasNaSequencia_cfg,
       int LimiteEntradaNaSequencia_cfg,
       int NumeroBlocosParaConsiderarAcerto_cfg,
       int NumeroDeSequenciasAnteriores_cfg)
   {
      ModoTamanhoBox = ModoTamanhoBox_cfg;
      TamanhoBoxFixo = TamanhoBoxFixo_cfg;
      PeriodoAtr = PeriodoAtr_cfg;
      MultiplicadorAtr = MultiplicadorAtr_cfg;
      ModoRenko = ModoRenko_cfg;
      TamanhoMinBox = TamanhoMinBox_cfg;
      TamanhoMaxBox = TamanhoMaxBox_cfg;
      BlocosEntrada = BlocosEntrada_cfg;
      AtivaLimiteSomaTempoBloco = AtivaLimiteSomaTempoBloco_cfg;
      LimiteSomaTempoBloco = LimiteSomaTempoBloco_cfg;
      AtivaLimiteEntradasNaSequencia = AtivaLimiteEntradasNaSequencia_cfg;
      LimiteEntradaNaSequencia = LimiteEntradaNaSequencia_cfg;
      NumeroBlocosParaConsiderarAcerto = NumeroBlocosParaConsiderarAcerto_cfg;
      NumeroDeSequenciasAnteriores = NumeroDeSequenciasAnteriores_cfg;
   }

   void Start()
   {
      RenkoHandle = iCustom(_Symbol, _Period, "IndicadorRenkoTupa_v06", ModoTamanhoBox, TamanhoBoxFixo, PeriodoAtr, MultiplicadorAtr, ModoRenko, TamanhoMinBox, TamanhoMaxBox, PlotarTempoBloco, NumeroBlocosParaConsiderarAcerto, NumeroDeSequenciasAnteriores);
      this.LerBuffers();
      UltimaSequencia = (int)RenkoSequence[0];

      LiberaPorTaxaCompra = true;
      LiberaPorTaxaVenda = true;
   }

   double RetornaBufferNaPosicao(int Buffer, int pos)
   {
      this.LerBuffers();
      switch (Buffer)
      {
      case 1:
         return RenkoOpen[pos];
         break;
      case 2:
         return RenkoClose[pos];
         break;
      case 3:
         return RenkoColor[pos];
         break;
      case 4:
         return RenkoColor[pos];
         break;
      case 5:
         return RenkoBlockTime[pos];
         break;
      case 6:
         return RenkoSequence[pos];
         break;
      default:
         return 0;
         break;
      }
   }

   int RetornaUltimaSequencia()
   {
      return UltimaSequencia;
   }

   double RetornaTamanhoBlocoAtual()
   {
      return RenkoTamanhoBox[0];
   }

   int NovosBlocos()
   {
      if (UltimaSequencia != (int)RenkoSequence[0])
      {
         int NovosBlocos = (int)(RenkoSequence[0] - UltimaSequencia);

         if (RenkoSequence[0] > 0)
         {
            if (UltimaSequencia < 0)
            {
               this.EntradasNaSequencia = 0;
               NovosBlocos = (int)RenkoSequence[0];
            }
         }
         else if (RenkoSequence[0] < 0)
         {
            if (UltimaSequencia > 0)
            {
               this.EntradasNaSequencia = 0;
               NovosBlocos = (int)RenkoSequence[0];
            }
         }

         UltimaSequencia = (int)RenkoSequence[0];

         return NovosBlocos;
      }

      return 0;
   }

   int SinalCompraOuVenda() //SINAL DE COMPRA OU VENDA 0=SEM SINAL, 1=COMPRA, 2=VENDA
   {

      int Sinal = 0;
      this.LerBuffers();

      if (NovosBlocos() != 0)
      {
         if (BlocosEntrada != 0 && UltimaSequencia >= BlocosEntrada)
         {
            Sinal = 1;

            if (AtivaLimiteSomaTempoBloco && SomaTempoUltimaSequencia() >= LimiteSomaTempoBloco)
               Sinal = 0;

            if (AtivaLimiteEntradasNaSequencia && this.EntradasNaSequencia >= LimiteEntradaNaSequencia)
               Sinal = 0;
         }
         else if (BlocosEntrada != 0 && UltimaSequencia <= BlocosEntrada * (-1))
         {
            Sinal = 2;

            if (AtivaLimiteSomaTempoBloco && SomaTempoUltimaSequencia() >= LimiteSomaTempoBloco)
               Sinal = 0;

            if (AtivaLimiteEntradasNaSequencia && this.EntradasNaSequencia >= LimiteEntradaNaSequencia)
               Sinal = 0;
         }
      }

      return Sinal;
   }

   void LiberadoPorTaxaCompra(bool SeparaTaxaCompraVenda_, double TaxaParaBloquear_, double TaxaParaLiberar_)
   {

      if (!SeparaTaxaCompraVenda_)
      {
         if (LiberaPorTaxaCompra && RenkoTaxaAcertoGeral[0] < TaxaParaBloquear_)
            LiberaPorTaxaCompra = false;
         else if (!LiberaPorTaxaCompra && RenkoTaxaAcertoGeral[0] >= TaxaParaLiberar_)
            LiberaPorTaxaCompra = true;
      }
      else if (LiberaPorTaxaCompra && RenkoTaxaAcertoCompra[0] < TaxaParaBloquear_)
         LiberaPorTaxaCompra = false;
      else if (!LiberaPorTaxaCompra && RenkoTaxaAcertoCompra[0] >= TaxaParaLiberar_)
         LiberaPorTaxaCompra = true;
   }

   void LiberadoPorTaxaVenda(bool SeparaTaxaCompraVenda_, double TaxaParaBloquear_, double TaxaParaLiberar_)
   {

      if (!SeparaTaxaCompraVenda_)
      {
         if (LiberaPorTaxaVenda && RenkoTaxaAcertoGeral[0] < TaxaParaBloquear_)
            LiberaPorTaxaVenda = false;

         else if (!LiberaPorTaxaVenda && RenkoTaxaAcertoGeral[0] >= TaxaParaLiberar_)
            LiberaPorTaxaVenda = true;
      }
      else if (LiberaPorTaxaVenda && RenkoTaxaAcertoVenda[0] < TaxaParaBloquear_)
         LiberaPorTaxaVenda = false;
      else if (!LiberaPorTaxaVenda && RenkoTaxaAcertoVenda[0] >= TaxaParaLiberar_)
         LiberaPorTaxaVenda = true;
   }

private:
   // Atributos privados
   double RenkoOpen[];
   double RenkoClose[];
   double RenkoColor[];
   double RenkoBlockTime[];
   double RenkoSequence[];
   double RenkoTaxaAcertoGeral[];
   double RenkoTaxaAcertoCompra[];
   double RenkoTaxaAcertoVenda[];
   double RenkoTamanhoBox[];

   int UltimaSequencia;

   //Métodos privados

   void LerBuffers()
   {
      CopyBuffer(RenkoHandle, 6, 0, 100, RenkoColor);

      CopyBuffer(RenkoHandle, 7, 0, 100, RenkoBlockTime);

      CopyBuffer(RenkoHandle, 8, 0, 100, RenkoSequence);

      CopyBuffer(RenkoHandle, 9, 0, 100, RenkoTaxaAcertoGeral);

      CopyBuffer(RenkoHandle, 10, 0, 100, RenkoTaxaAcertoCompra);

      CopyBuffer(RenkoHandle, 11, 0, 100, RenkoTaxaAcertoVenda);

      CopyBuffer(RenkoHandle, 12, 0, 100, RenkoTamanhoBox);
   }

   ulong SomaTempoUltimaSequencia()
   {
      ulong SumBlockTime = 0;
      for (int i = 0; i < BlocosEntrada; i++)
      {
         SumBlockTime = (ulong)(SumBlockTime + RenkoBlockTime[i]);
      }
      return SumBlockTime;
   }
};
//+------------------------------------------------------------------+
