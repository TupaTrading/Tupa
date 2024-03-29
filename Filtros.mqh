//+------------------------------------------------------------------+
//|                                                     RoboTupa.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

enum TIPO_FILTRO
{
   NONE,
   HILO,
   MA_DISTANCE,
   SUP_RES_ZONE,
   RVI,
   ATR,
   VOL_RATE,
   DELTA
};
enum TIPO_RVI
{
   OR,
   AND
};
enum TIPO_VOL_RATE
{
   AUTOMATICO,
   MANUAL
};
enum MAIN_INDICATOR
{
   DELTA_,
   VOLUME_
};

class Filtros
{
public:
   TIPO_FILTRO Tipo;

   uint PeriodoHiLo;
   ENUM_MA_METHOD ModoHiLo;
   double DistanciaHiLo;

   int PeriodoCurtaMA;
   int ShiftCurtaMA;
   ENUM_MA_METHOD ModoCurtaMA;
   int PeriodoLongaMA;
   int ShiftLongaMA;
   ENUM_MA_METHOD ModoLongaMA;
   double DistanciaMA;

   double TamanhoZonaSupRes;

   int PeriodoRvi;
   bool AguardaCandle;
   double RviValueMin;
   double SignalRviValueMin;
   double RviValueMax;
   double SignalRviValueMax;
   double MaxRampaRvi;
   double MinRampaRvi;
   double DistanciaRviSignal;
   TIPO_RVI TipoFiltroRvi;

   int PeriodoAtr;

   ENUM_APPLIED_VOLUME InpVolumeType;
   double VolMin;
   TIPO_VOL_RATE TipoVolRate;
   int PeriodoMediaVol;
   ENUM_MA_METHOD ma_method;
   double TaxaRompimento;
   double VolPorCandle;
   double TaxaMedia;

   double TargetValueBuySellRate;
   datetime inpHistoryDate;
   double SamplingTime;
   int MeanPeriod;
   bool ShowRealVolume;
   MAIN_INDICATOR MainIndicator;
   double MultDelta;

   int IndicadorHandle1;
   int IndicadorHandle2;

   Filtros()
   {
      Tipo = NONE;

      IndicadorHandle1 = INVALID_HANDLE;
      IndicadorHandle2 = INVALID_HANDLE;

      PeriodoHiLo = 14;
      ModoHiLo = MODE_SMA;
      DistanciaHiLo = 100;
      ArraySetAsSeries(HiLo, true);

      PeriodoCurtaMA = 14;
      ShiftCurtaMA = 0;
      ModoCurtaMA = MODE_EMA;
      PeriodoLongaMA = 26;
      ShiftLongaMA = 0;
      ModoLongaMA = MODE_EMA;
      DistanciaMA = 50;
      ArraySetAsSeries(MACurta, true);
      ArraySetAsSeries(MALonga, true);

      TamanhoZonaSupRes = 100;
      ArraySetAsSeries(Suporte, true);
      ArraySetAsSeries(Resistencia, true);
      ArraySetAsSeries(Close, true);

      PeriodoRvi = 1;
      AguardaCandle = false;
      RviValueMin = 0;
      SignalRviValueMin = 0;
      RviValueMax = 0;
      SignalRviValueMax = 0;
      MaxRampaRvi = 0.3;
      MinRampaRvi = 0.2;
      DistanciaRviSignal = 0.2;
      TipoFiltroRvi = OR;
      ArraySetAsSeries(Rvi, true);
      ArraySetAsSeries(SignalRvi, true);

      PeriodoAtr = 5;

      InpVolumeType = VOLUME_TICK;
      VolMin = 2000;
      TipoVolRate = MANUAL;
      ma_method = MODE_SMA;
      VolPorCandle = 0;
      PeriodoMediaVol = 30;
      TaxaRompimento = 2;
      ArraySetAsSeries(VolRate, true);
      ArraySetAsSeries(Vol, true);
      ArraySetAsSeries(MAVolRate, true);

      TargetValueBuySellRate = 1;
      SamplingTime = 50;
      MeanPeriod = 50;
      ShowRealVolume = false;
      MainIndicator = DELTA_;
      MultDelta = 1;
      ArraySetAsSeries(DeltaFactor, true);
   }

   ~Filtros()
   {
   }

   void Start()
   {
      switch (Tipo)
      {
      case NONE:
      default:
         break;

      case HILO:
         this.IndicadorHandle1 = iCustom(_Symbol, _Period, "hilo", PeriodoHiLo, ModoHiLo, DistanciaHiLo);
         break;

      case MA_DISTANCE:
         this.IndicadorHandle1 = iMA(_Symbol, _Period, PeriodoCurtaMA, ShiftCurtaMA, ModoCurtaMA, PRICE_CLOSE);
         this.IndicadorHandle2 = iMA(_Symbol, _Period, PeriodoLongaMA, ShiftLongaMA, ModoLongaMA, PRICE_CLOSE);
         break;
      case SUP_RES_ZONE:
         this.IndicadorHandle1 = iCustom(_Symbol, _Period, "Support_and_Resistance");
         break;
      case RVI:
         this.IndicadorHandle1 = iRVI(_Symbol, _Period, PeriodoRvi);
         break;
      case ATR:
         this.IndicadorHandle1 = iATR(_Symbol, _Period, PeriodoAtr);
         break;
      case VOL_RATE:
         this.IndicadorHandle1 = iCustom(_Symbol, _Period, "Volumes_TupaV1", InpVolumeType);

         if (TipoVolRate == AUTOMATICO)
            this.IndicadorHandle2 = iMA(_Symbol, _Period, PeriodoMediaVol, 0, ma_method, IndicadorHandle1);
         else
            TaxaMedia = (double)VolPorCandle / (double)60;
         break;
      case DELTA:
         this.IndicadorHandle1 = iCustom(_Symbol, _Period, "DeltaTupaV2", MainIndicator, inpHistoryDate, clrDodgerBlue, clrRed, 3, false, SamplingTime, MeanPeriod, ShowRealVolume);
         this.IndicadorHandle2 = iMA(_Symbol, _Period, 30, 0, MODE_SMA, IndicadorHandle1);
         break;
      }
   }

   bool LiberaCompra()

   {
      return VerificaCompra(0);
   }

   bool LiberaVenda()

   {
      return VerificaVenda(0);
   }

   bool LiberaCompra(double boxsize)

   {
      return VerificaCompra(boxsize);
   }

   bool LiberaVenda(double boxsize)

   {
      return VerificaVenda(boxsize);
   }

   bool VerificaSaidaDeCompraRvi(double tol)
   {
      if (Tipo == RVI)
      {
         CopyBuffer(IndicadorHandle1, 0, 0, 2, Rvi);
         CopyBuffer(IndicadorHandle1, 1, 0, 2, SignalRvi);

         if (Rvi[0] < SignalRvi[0] - tol || Rvi[0] < 0)
            return true;
      }
      return false;
   }

   bool VerificaSaidaDeVendaRvi(double tol)
   {
      if (Tipo == RVI)
      {
         CopyBuffer(IndicadorHandle1, 0, 0, 2, Rvi);
         CopyBuffer(IndicadorHandle1, 1, 0, 2, SignalRvi);

         if (Rvi[0] > SignalRvi[0] + tol || Rvi[0] > 0)
            return true;
      }
      return false;
   }

private:
   double HiLo[];

   double MACurta[];
   double MALonga[];

   double Suporte[];
   double Resistencia[];
   double Close[];
   double ZonaResistanceMin;
   double ZonaResistanceMax;
   double ZonaSuporteMin;
   double ZonaSuporteMax;

   double Rvi[];
   double SignalRvi[];

   double Atr[];

   double VolRate[];
   double Vol[];
   double MAVolRate[];

   double Delta[];
   double DeltaFactor[];
   double MADelta[];

   bool VerificaCompra(double boxsize)
   {

      switch (Tipo)
      {

      case NONE:
      default:
         break;

      case HILO:
         CopyBuffer(IndicadorHandle1, 1, 0, 1, HiLo);
         if (HiLo[0] == 0)
            return true;
         break;
      case MA_DISTANCE:
         CopyBuffer(IndicadorHandle1, 0, 0, 3, MACurta);
         CopyBuffer(IndicadorHandle2, 0, 0, 3, MALonga);
         if (MACurta[0] - MALonga[0] >= DistanciaMA)
            return true;
         break;
      case SUP_RES_ZONE:
         CopyBuffer(IndicadorHandle1, 0, 0, 1, Resistencia);
         CopyClose(_Symbol, _Period, 0, 1, Close);

         ZonaResistanceMin = Resistencia[0] - (TamanhoZonaSupRes / 2);
         ZonaResistanceMax = Resistencia[0] + (TamanhoZonaSupRes / 2);

         if (Close[0] < ZonaResistanceMin || Close[0] > ZonaResistanceMax)
         {
            printf("Fora da Zona de Resistencia");
            return true;
         }

         break;
      case RVI:
      {

         CopyBuffer(IndicadorHandle1, 0, 0, 3, Rvi);
         CopyBuffer(IndicadorHandle1, 1, 0, 3, SignalRvi);
         int i1;
         int i2;

         if (AguardaCandle)
         {
            i1 = 1;
            i2 = 2;
         }
         else
         {
            i1 = 0;
            i2 = 1;
         }

         switch (TipoFiltroRvi)
         {
         case OR:
            if (Rvi[i1] >= RviValueMin || SignalRvi[i1] >= SignalRviValueMin)
               if (Rvi[i1] <= RviValueMax || SignalRvi[i1] <= SignalRviValueMax)
                  if (Rvi[i1] - Rvi[i2] >= MinRampaRvi && Rvi[i1] - Rvi[i2] <= MaxRampaRvi)
                     if (Rvi[i1] - SignalRvi[i1] >= DistanciaRviSignal)
                        return true;
            break;
         case AND:
            if (Rvi[i1] >= RviValueMin && SignalRvi[i1] >= SignalRviValueMin)
               if (Rvi[i1] <= RviValueMax && SignalRvi[i1] <= SignalRviValueMax)
                  if (Rvi[i1] - Rvi[i2] >= MinRampaRvi && Rvi[i1] - Rvi[i2] <= MaxRampaRvi)
                     if (Rvi[i1] - SignalRvi[i1] >= DistanciaRviSignal)
                        return true;
            break;
         }
         break;
      }
      case ATR:
         CopyBuffer(IndicadorHandle1, 0, 0, 1, Atr);
         if (boxsize == 0)
            Print("Erro Filtro ATR");
         else if (Atr[0] >= boxsize)
            return true;
         break;
      case VOL_RATE:
      {
         CopyBuffer(IndicadorHandle1, 0, 0, 1, Vol);
         CopyBuffer(IndicadorHandle1, 2, 0, 1, VolRate);

         if (TipoVolRate == AUTOMATICO)
         {
            CopyBuffer(IndicadorHandle2, 0, 0, 1, MAVolRate);
            VolPorCandle = MAVolRate[0] * TaxaRompimento;
            TaxaMedia = (double)VolPorCandle / (double)60;
         }

         if (VolRate[0] > TaxaMedia && Vol[0] > VolMin)
            return true;
         break;
      }
      case DELTA:

         do
         {
            CopyBuffer(IndicadorHandle1, 0, 0, 1, Delta);
            CopyBuffer(IndicadorHandle1, 8, 0, 1, DeltaFactor);
            CopyBuffer(IndicadorHandle2, 0, 0, 1, MADelta);

         } while (DeltaFactor[0] == 1.7976931348623157E+308);

         if (DeltaFactor[0] > TargetValueBuySellRate && Delta[0] > MADelta[0] * MultDelta)
         {
            return true;
         }
         break;
      }
      return false;
   }

   bool VerificaVenda(double boxsize)
   {
      switch (Tipo)
      {
      case NONE:
      default:
         break;

      case HILO:
         CopyBuffer(IndicadorHandle1, 1, 0, 1, HiLo);
         if (HiLo[0] == 1)
            return true;
         break;

      case MA_DISTANCE:
         CopyBuffer(IndicadorHandle1, 0, 0, 3, MACurta);
         CopyBuffer(IndicadorHandle2, 0, 0, 3, MALonga);

         if (MALonga[0] - MACurta[0] >= DistanciaMA)
            return true;
         break;
      case SUP_RES_ZONE:
         CopyBuffer(IndicadorHandle1, 0, 0, 1, Suporte);
         CopyClose(_Symbol, _Period, 0, 1, Close);

         ZonaSuporteMin = Suporte[0] - (TamanhoZonaSupRes / 2);
         ZonaSuporteMax = Suporte[0] + (TamanhoZonaSupRes / 2);

         if (Close[0] < ZonaSuporteMin || Close[0] > ZonaSuporteMax)
         {
            printf("Fora da Zona de Suporte");
            return true;
         }
         break;
      case RVI:
      {
         CopyBuffer(IndicadorHandle1, 0, 0, 3, Rvi);
         CopyBuffer(IndicadorHandle1, 1, 0, 3, SignalRvi);
         int i1;
         int i2;

         if (AguardaCandle)
         {
            i1 = 1;
            i2 = 2;
         }
         else
         {
            i1 = 0;
            i2 = 1;
         }

         switch (TipoFiltroRvi)
         {
         case OR:
            if (Rvi[i1] <= (RviValueMin) * (-1) || SignalRvi[i1] <= (SignalRviValueMin) * (-1))
               if (Rvi[i1] >= (RviValueMax) * (-1) || SignalRvi[i1] >= (SignalRviValueMax) * (-1))
                  if (Rvi[i2] - Rvi[i1] >= MinRampaRvi && Rvi[i2] - Rvi[i1] <= MaxRampaRvi)
                     if (SignalRvi[i1] - Rvi[i1] >= DistanciaRviSignal)
                        return true;
            break;
         case AND:
            if (Rvi[i1] <= (RviValueMin) * (-1) && SignalRvi[i1] <= (SignalRviValueMin) * (-1))
               if (Rvi[i1] >= (RviValueMax) * (-1) && SignalRvi[i1] >= (SignalRviValueMax) * (-1))
                  if (Rvi[i2] - Rvi[i1] >= MinRampaRvi && Rvi[i2] - Rvi[i1] <= MaxRampaRvi)
                     if (SignalRvi[i1] - Rvi[i1] >= DistanciaRviSignal)
                        return true;
            break;
         }
         break;
      }
      case ATR:
         CopyBuffer(IndicadorHandle1, 0, 0, 1, Atr);
         if (boxsize == 0)
            Print("Erro Filtro ATR");
         else if (Atr[0] >= boxsize)
            return true;
         break;
      case VOL_RATE:
      {
         CopyBuffer(IndicadorHandle1, 0, 0, 1, Vol);
         CopyBuffer(IndicadorHandle1, 2, 0, 1, VolRate);

         if (TipoVolRate == AUTOMATICO)
         {
            CopyBuffer(IndicadorHandle2, 0, 0, 1, MAVolRate);
            VolPorCandle = MAVolRate[0] * TaxaRompimento;
            TaxaMedia = (double)VolPorCandle / (double)60;
         }

         if (VolRate[0] > TaxaMedia && Vol[0] > VolMin)
            return true;
         break;
      }
      case DELTA:

         do
         {
            CopyBuffer(IndicadorHandle1, 0, 0, 1, Delta);
            CopyBuffer(IndicadorHandle1, 8, 0, 1, DeltaFactor);
            CopyBuffer(IndicadorHandle2, 0, 0, 1, MADelta);

         } while (DeltaFactor[0] == 1.7976931348623157E+308);

         if (DeltaFactor[0] < TargetValueBuySellRate * (-1) && Delta[0] > MADelta[0] * MultDelta)
         {
            return true;
         }
         break;
      }
      return false;
   }
};