//+------------------------------------------------------------------+
//|                                                     RoboTupa.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ControleTrade
{

public:
  //ATRIBUTOS PÚBLICOS

  //Configurações----------------------
  int HoradeInicio;
  int MinutodeInicio;
  int HoradeEncerramento;
  int MinutodeEncerramento;

  bool FinancialLimitEnable;
  double MetaGanhoDia;
  double ValorMaximoPerdaDia;

  int Magic;
  ulong Slippage;

  int Lote;

  double TakeProfitFixo;
  double StopLossFixo;

  bool TakeProfitAtrAtivado;
  int PeriodoAtrTakeProfit;
  double MultiplicadorTakeProfitAtr;

  bool StopLossAtrAtivado;
  int PeriodoAtrStopLoss;
  double MultiplicadorStopLossAtr;

  double InicioStopMovel;
  double StopMovel;
  double PassoStopMovel;

  //-----------------------------------

  double GanhoMaxDoDia;

  //MÉTODOS PÚBLICOS

  ControleTrade()
  {
    HoradeInicio = 10;
    MinutodeInicio = 0;
    HoradeEncerramento = 17;
    MinutodeEncerramento = 0;

    FinancialLimitEnable = false;

    datetime dtm = TimeCurrent();
    Magic = (int)(ulong)dtm;

    Slippage = 0;

    AtrStopLossHandle = INVALID_HANDLE;
    AtrTakeProfitHandle = INVALID_HANDLE;

    ArraySetAsSeries(AtrStopLoss, true);
    ArraySetAsSeries(AtrTakeProfit, true);
  }
  //+------------------------------------------------------------------+
  //|                                                                  |
  //+------------------------------------------------------------------+
  ~ControleTrade()
  {
  }

  void ConfiguraTrade(
      int Cfg_HoraDeInicio,
      int Cfg_MinutoDeInicio,
      int Cfg_HoradeEncerramento,
      int Cfg_MinutodeEncerramento,

      bool Cfg_FinancialLimitEnable,
      double Cfg_MetaGanhoDia,
      double Cfg_ValorMaximoPerdaDia,

      int Cfg_Magic,
      ulong Cfg_Slippage,

      int Cfg_Lote,

      double Cfg_TakeProfitFixo,
      double Cfg_StopLossFixo,

      bool Cfg_TakeProfitAtrAtivado,
      int Cfg_PeriodoAtrTakeProfit,
      double Cfg_MultiplicadorTakeProfitAtr,

      bool Cfg_StopLossAtrAtivado,
      int Cfg_PeriodoAtrStopLoss,
      double Cfg_MultiplicadorStopLossAtr,

      double Cfg_InicioStopMovel,

      double Cfg_PassoStopMovel)
  {
    HoradeInicio = Cfg_HoraDeInicio;
    MinutodeInicio = Cfg_MinutoDeInicio;
    HoradeEncerramento = Cfg_HoradeEncerramento;
    MinutodeEncerramento = Cfg_MinutodeEncerramento;

    FinancialLimitEnable = Cfg_FinancialLimitEnable;
    MetaGanhoDia = Cfg_MetaGanhoDia;
    ValorMaximoPerdaDia = Cfg_ValorMaximoPerdaDia;

    if (Cfg_Magic != 0)
      Magic = Cfg_Magic;
    Slippage = Cfg_Slippage;

    Lote = Cfg_Lote;

    StopLossFixo = Cfg_StopLossFixo;
    TakeProfitFixo = Cfg_TakeProfitFixo;

    TakeProfitAtrAtivado = Cfg_TakeProfitAtrAtivado;
    PeriodoAtrTakeProfit = Cfg_PeriodoAtrTakeProfit;
    MultiplicadorTakeProfitAtr = Cfg_MultiplicadorTakeProfitAtr;

    StopLossAtrAtivado = Cfg_StopLossAtrAtivado;
    PeriodoAtrStopLoss = Cfg_PeriodoAtrStopLoss;
    MultiplicadorStopLossAtr = Cfg_MultiplicadorStopLossAtr;

    InicioStopMovel = Cfg_InicioStopMovel;

    PassoStopMovel = Cfg_PassoStopMovel;
  }

  bool ActualyOnWorkPeriod()
  {

    MqlDateTime stm;
    datetime tm = TimeCurrent(stm);
    if (int(stm.hour) > HoradeEncerramento)
    {
      return false;
    }
    if (int(stm.hour) == HoradeEncerramento)
    {
      if (int(stm.min) > MinutodeEncerramento)
      {
        return false;
      }
      else
      {
        return true;
      }
    }
    if (int(stm.hour) > HoradeInicio)
    {
      return true;
    }
    if (int(stm.hour) == HoradeInicio)
    {
      if (int(stm.min) >= MinutodeInicio)
      {
        return true;
      }
      else
      {
        return false;
      }
    }
    return false;
  }

  bool CorrigirPosicao(ulong magic, ulong slippage, double sl_, double tp_)
  {
    double high_ = 0;
    double low_ = 0;

    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic)
      {

        ulong ticket = PositionGetTicket(i);
        double op = PositionGetDouble(POSITION_PRICE_OPEN);

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          return (ModificarPosicao(ticket, op - sl_, op + tp_));

        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
          return (ModificarPosicao(ticket, op + sl_, op - tp_));
      }
    }
    return false;
  }

  int AjustaStopMovel(double InicioStopMovel_, double StopMovel_, double PassoStopMovel_)
  {
    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
      {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
          ulong ticket = PositionGetTicket(i);
          double pp = SymbolInfoDouble(_Symbol, SYMBOL_BID);
          double sl = PositionGetDouble(POSITION_SL);
          double op = PositionGetDouble(POSITION_PRICE_OPEN);
          double tp = PositionGetDouble(POSITION_TP);

          if (pp - op >= InicioStopMovel_)
          {
            if (sl < pp - (StopMovel_ + PassoStopMovel_) || sl == 0)
            {
              ModificarPosicao(ticket, pp - (StopMovel_ + PassoStopMovel_), tp);
            }
          }
        }
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
          ulong ticket = PositionGetTicket(i);
          double pp = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          double sl = PositionGetDouble(POSITION_SL);
          double op = PositionGetDouble(POSITION_PRICE_OPEN);
          double tp = PositionGetDouble(POSITION_TP);

          if (op - pp >= InicioStopMovel_)
          {
            if (sl > pp + (StopMovel_ + PassoStopMovel_) || sl == 0)
            {
              ModificarPosicao(ticket, pp + (StopMovel_ + PassoStopMovel_), tp);
            }
          }
        }
      }
    }

    return (0);
  }

  void Start()
  {
    if (TakeProfitAtrAtivado)
      AtrTakeProfitHandle = iATR(_Symbol, 0, PeriodoAtrTakeProfit);
    if (StopLossAtrAtivado)
      AtrStopLossHandle = iATR(_Symbol, 0, PeriodoAtrStopLoss);
  }

  bool Comprado()
  {
    this.ContaPosicoes();
    return (ContadorCompras > 0);
  }

  bool Vendido()
  {
    this.ContaPosicoes();
    return (ContadorVendas > 0);
  }

  void EncerraTodasPosicoes(ulong magic, ulong slippage)
  {
    this.EncerraTodasCompras(magic, slippage);
    this.EncerraTodasVendas(magic, slippage);
  }

  double RetornaLucroUltimaTransacao()
  {
    return GetLastTransactionProfit();
  }

  bool EstaNoPeriodoDeTrabalho()
  {
    return ActualyOnWorkPeriod();
  }

  double RetornaStopLoss()
  {
    return this.CalculaStopLoss();
  }

  double RetornaTakeProfit()
  {
    return this.CalculaTakeProfit();
  }

  void EncerraPosicoesPorStopinho(int CorUltimoBlocoRenko)
  {
    if (this.Comprado() && CorUltimoBlocoRenko == 1)
      EncerraTodasCompras(this.Magic, this.Slippage);

    if (this.Vendido() && CorUltimoBlocoRenko == 0)
      EncerraTodasVendas(this.Magic, this.Slippage);
  }

  int Compra(ulong slippage, double l, double SL, double TP, int magic)
  {

    MqlTradeRequest request;
    MqlTradeResult result;
    MqlTradeCheckResult check;
    ZeroMemory(request);
    ZeroMemory(result);
    ZeroMemory(check);

    int digit = int(SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    long ds = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double minl = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double po = NormalizeDouble(Ask, digit);

    double lot = l;
    lot = NormalizeDouble(lot, 2);
    if (lot < minl)
      lot = minl;

    double tp = 0;
    double sl = 0;

    //if(TP>0)tp=Bid+TP;
    //if(SL>0)sl=Bid-SL;

    request.type = ORDER_TYPE_BUY;
    request.price = po;
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lot;
    request.magic = magic;
    //   request.comment=Comm;
    request.tp = tp;
    request.sl = sl;
    request.type_filling = ORDER_FILLING_FOK;
    request.deviation = slippage;
    if (!DailyResultOutOfLimit())
    {
      if (ActualyOnWorkPeriod())
      {
        if (!OrderCheck(request, check))
        {
          Print(__FUNCTION__, "(): Error inputs for trade order");
          Print(__FUNCTION__, "(): OrderCheck(): ", CodigoErroResultado(check.retcode));
          return (-1);
        }
        if (!OrderSend(request, result) || result.retcode != TRADE_RETCODE_DONE)
        {
          Print(__FUNCTION__, "(): Unable to make the transaction");
          Print(__FUNCTION__, "(): OrderSend(): ", CodigoErroResultado(result.retcode));
          return (-1);
        }
        else
        {
          if (result.retcode != TRADE_RETCODE_DONE)

          {
            Print(__FUNCTION__, "(): Unable to make the transaction");
            Print(__FUNCTION__, "(): OrderSend(): ", CodigoErroResultado(result.retcode));
            return (-1);
          }
          else
          {
            PosicaoCorrigida = CorrigirPosicao(magic, slippage, SL > 0 ? SL : 0, TP > 0 ? TP : 0);
          }
        }
      }
      else
        Print("Compra não enviada por estar fora do horário de tabalho do robo");
    }

    return (0);
  }
  //+------------------------------------------------------------------+

  int Venda(ulong slippage, double l, double SL, double TP, int magic)
  {

    MqlTradeRequest request;
    MqlTradeResult result;
    MqlTradeCheckResult check;
    ZeroMemory(request);
    ZeroMemory(result);
    ZeroMemory(check);

    int digit = int(SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    long ds = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double minl = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double po = NormalizeDouble(Bid, digit);

    double lot = l;
    lot = NormalizeDouble(lot, 2);
    if (lot < minl)
      lot = minl;

    double tp = 0;
    double sl = 0;

    //if(TP>0)tp=Bid-TP;
    //if(SL>0)sl=Bid+SL;

    request.type = ORDER_TYPE_SELL;
    request.price = po;
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lot;
    request.magic = magic;
    //  request.comment=Comm;
    request.tp = tp;
    request.sl = sl;
    request.type_filling = ORDER_FILLING_FOK;
    request.deviation = slippage;
    if (!DailyResultOutOfLimit())
    {
      if (ActualyOnWorkPeriod())
      {
        if (!OrderCheck(request, check))
        {
          Print(__FUNCTION__, "(): Error inputs for trade order");
          Print(__FUNCTION__, "(): OrderCheck(): ", CodigoErroResultado(check.retcode));
          return (-1);
        }
        if (!OrderSend(request, result) || result.retcode != TRADE_RETCODE_DONE)
        {
          Print(__FUNCTION__, "(): Unable to make the transaction");
          Print(__FUNCTION__, "(): OrderSend(): ", CodigoErroResultado(result.retcode));
          return (-1);
        }
        else
        {
          if (result.retcode != TRADE_RETCODE_DONE)
          {
            Print(__FUNCTION__, "(): Unable to make the transaction");
            Print(__FUNCTION__, "(): OrderSend(): ", CodigoErroResultado(result.retcode));
            return (-1);
          }
          else
          {
            PosicaoCorrigida = CorrigirPosicao(magic, slippage, SL > 0 ? SL : 0, TP > 0 ? TP : 0);
          }
        }
      }
      else
        Print("Venda não enviada por estar fora do horário de tabalho do robo");
    }
    return (0);
  }

  double NormalizePrice(double price)
  {
    double price_step = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double round_price = price_step * MathRound(price / price_step);
    return round_price;
  }

private:
  //ATRIBUTOS PRIVADOS

  //Internos

  int ContadorCompras;
  int ContadorVendas;

  int AtrTakeProfitHandle;
  int AtrStopLossHandle;

  double AtrStopLoss[];
  double AtrTakeProfit[];

  //MÉTODOS PRIVADOS

  double CalculaStopLoss()
  {
    if (StopLossAtrAtivado)
    {
      CopyBuffer(AtrStopLossHandle, 0, 0, 1, AtrStopLoss);
      return NormalizePrice(AtrStopLoss[0] * MultiplicadorStopLossAtr);
    }
    else
    {
      return NormalizePrice(StopLossFixo);
    }
  }

  double CalculaTakeProfit()
  {
    if (TakeProfitAtrAtivado)
    {
      CopyBuffer(AtrTakeProfitHandle, 0, 0, 1, AtrTakeProfit);
      return NormalizePrice(AtrTakeProfit[0] * MultiplicadorTakeProfitAtr);
    }
    else
    {
      return NormalizePrice(TakeProfitFixo);
    }
  }

  //+------------------------------------------------------------------+

  int BreakEven(double GatilhoBreakEven, double BreakEven)
  {
    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
      {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
          ulong ticket = PositionGetTicket(i);
          double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          double sl = PositionGetDouble(POSITION_SL);
          double op = PositionGetDouble(POSITION_PRICE_OPEN);
          double tp = PositionGetDouble(POSITION_TP);
          if ((bid - op) > GatilhoBreakEven)
          {

            double sl1 = NormalizePrice(op + (BreakEven));
            if (sl1 != sl)
            {
              ModificarPosicao(ticket, sl1, tp);
            }
          }
        }
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
          ulong ticket = PositionGetTicket(i);
          double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
          double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
          double sl = PositionGetDouble(POSITION_SL);
          double op = PositionGetDouble(POSITION_PRICE_OPEN);
          double tp = PositionGetDouble(POSITION_TP);
          if ((op - ask) > GatilhoBreakEven)
          {

            double sl1 = NormalizePrice(op - (BreakEven));
            if (sl1 != sl)
            {
              ModificarPosicao(ticket, sl1, tp);
            }
          }
        }
      }
    }

    return (0);
  }
  //+------------------------------------------------------------------+

  bool ModificarPosicao(ulong ticket, double sl, double tp)
  {

    //sl = NormalizePrice(sl);
    //tp = NormalizePrice(tp);

    MqlTradeRequest request;
    MqlTradeResult result;
    MqlTradeCheckResult check;
    ZeroMemory(request);
    ZeroMemory(result);
    ZeroMemory(check);
    request.action = TRADE_ACTION_SLTP;
    request.position = ticket;
    request.symbol = _Symbol;
    request.sl = sl;
    request.tp = tp;
    request.magic = Magic;

    if (PositionGetDouble(POSITION_TP) != tp || PositionGetDouble(POSITION_SL) != sl)
    {
      if (!OrderCheck(request, check))
      {
        Print(__FUNCTION__, "(): Error inputs for trade order");
        Print(__FUNCTION__, "(): OrderCheck(): ", CodigoErroResultado(check.retcode));
        return (false);
      }
      if (!OrderSend(request, result) || result.retcode != TRADE_RETCODE_DONE)
      {
        Print(__FUNCTION__, "(): Unable to modify");
        Print(__FUNCTION__, "(): Modify(): ", CodigoErroResultado(result.retcode));
        return (false);
      }
      else if (result.retcode != TRADE_RETCODE_DONE)

      {
        Print(__FUNCTION__, "(): Unable to modify");
        Print(__FUNCTION__, "(): Modify(): ", CodigoErroResultado(result.retcode));
        return (false);
      }
    }
    else
      Print("TP e SL já estavam corretos");

    return (true);
  }
  //+------------------------------------------------------------------+

  string CodigoErroResultado(int retcode)
  {
    string str;
    //----
    switch (retcode)
    {
    case TRADE_RETCODE_REQUOTE:
      str = "Requote";
      break;
    case TRADE_RETCODE_REJECT:
      str = "Rejected";
      break;
    case TRADE_RETCODE_CANCEL:
      str = "Cancelled";
      break;
    case TRADE_RETCODE_PLACED:
      str = "Order placed";
      break;
    case TRADE_RETCODE_DONE:
      str = "Request done";
      break;
    case TRADE_RETCODE_DONE_PARTIAL:
      str = "Request done partial";
      break;
    case TRADE_RETCODE_INVALID:
      str = "Invalid request";
      break;
    case TRADE_RETCODE_INVALID_VOLUME:
      str = "Invalid volume";
      break;
    case TRADE_RETCODE_INVALID_PRICE:
      str = "Invalid price";
      break;
    case TRADE_RETCODE_INVALID_STOPS:
      str = "INVALID STOPS";
      break;
    case TRADE_RETCODE_TRADE_DISABLED:
      str = "Trade disabled";
      break;
    case TRADE_RETCODE_MARKET_CLOSED:
      str = "Market closed";
      break;
    case TRADE_RETCODE_NO_MONEY:
      str = "Of insufficient funds";
      break;
    case TRADE_RETCODE_PRICE_CHANGED:
      str = "Price changed";
      break;
    case TRADE_RETCODE_ORDER_CHANGED:
      str = "Order changed ";
      break;
    case TRADE_RETCODE_TOO_MANY_REQUESTS:
      str = "Too many requests";
      break;
    case TRADE_RETCODE_NO_CHANGES:
      str = "No changes";
      break;
    case TRADE_RETCODE_SERVER_DISABLES_AT:
      str = "Server disables autotrading";
      break;
    case TRADE_RETCODE_CLIENT_DISABLES_AT:
      str = "Client disables autotrading";
      break;
    case TRADE_RETCODE_LOCKED:
      str = "Request is locked";
      break;
    case TRADE_RETCODE_LIMIT_ORDERS:
      str = "Limit orders";
      break;
    case TRADE_RETCODE_LIMIT_VOLUME:
      str = "Limit volume";
      break;
    default:
      str = "Unknown error " + IntegerToString(retcode);
    }
    //----
    return (str);
  }
  //+------------------------------------------------------------------+

  //+------------------------------------------------------------------+

  int ContaPosicoes()
  {
    ContadorCompras = 0;
    ContadorVendas = 0;

    for (int i = 0; i < PositionsTotal(); i++)
    {
      if (PositionGetSymbol(i) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
      {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
        {
          ContadorCompras++;
        }
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
        {
          ContadorVendas++;
        }
      }
    }
    return (0);
  }

  //+------------------------------------------------------------------+
  int EncerraTodasCompras(ulong magic, ulong slippage)
  {
    MqlTradeRequest request;
    MqlTradeResult result;
    int total = PositionsTotal();
    for (int i = total - 1; i >= 0; i--)
    {

      ulong position_ticket = PositionGetTicket(i);                        // тикет позиции
      string position_symbol = PositionGetString(POSITION_SYMBOL);         // символ
      int digits = (int)SymbolInfoInteger(position_symbol, SYMBOL_DIGITS); // количество знаков после запятой
      //ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // Magicumber позиции
      double volume = PositionGetDouble(POSITION_VOLUME);                              // объем позиции
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // тип позиции

      if ((position_symbol == _Symbol) && (type == POSITION_TYPE_BUY) && PositionGetInteger(POSITION_MAGIC) == Magic)
      {

        ZeroMemory(request);
        ZeroMemory(result);

        request.action = TRADE_ACTION_DEAL;
        request.position = position_ticket;
        request.symbol = position_symbol;
        request.volume = volume;
        request.deviation = slippage;
        request.magic = magic;

        request.price = SymbolInfoDouble(position_symbol, SYMBOL_BID);
        request.type = ORDER_TYPE_SELL;

        if (!OrderSend(request, result))
          PrintFormat("OrderSend error %d", GetLastError()); // если отправить запрос не удалось, вывести код ошибки
      }
    }
    return (0);
  }
  //+------------------------------------------------------------------+
  int EncerraTodasVendas(ulong magic, ulong slippage)
  {
    MqlTradeRequest request;
    MqlTradeResult result;
    int total = PositionsTotal();
    for (int i = total - 1; i >= 0; i--)
    {

      ulong position_ticket = PositionGetTicket(i);                        // тикет позиции
      string position_symbol = PositionGetString(POSITION_SYMBOL);         // символ
      int digits = (int)SymbolInfoInteger(position_symbol, SYMBOL_DIGITS); // количество знаков после запятой
      //ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // Magicumber позиции
      double volume = PositionGetDouble(POSITION_VOLUME);                              // объем позиции
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // тип позиции

      if ((position_symbol == _Symbol) && (type == POSITION_TYPE_SELL) && PositionGetInteger(POSITION_MAGIC) == Magic)
      {
        //--- обнуление значений запроса и результата
        ZeroMemory(request);
        ZeroMemory(result);
        //--- установка параметров операции
        request.action = TRADE_ACTION_DEAL;
        request.position = position_ticket;
        request.symbol = position_symbol;
        request.volume = volume;
        request.deviation = slippage;
        request.magic = magic;

        request.price = SymbolInfoDouble(position_symbol, SYMBOL_ASK);
        request.type = ORDER_TYPE_BUY;

        if (!OrderSend(request, result))
          PrintFormat("OrderSend error %d", GetLastError()); // если отправить запрос не удалось, вывести код ошибки
      }
    }
    return (0);
  }
  //+------------------------------------------------------------------+

  bool DailyResultOutOfLimit()
  {
    string tmp_x;
    double tmp_resultado_financeiro_dia;
    int tmp_contador;
    MqlDateTime tmp_data_b;

    TimeCurrent(tmp_data_b);
    tmp_resultado_financeiro_dia = 0;
    tmp_x = string(tmp_data_b.year) + "." + string(tmp_data_b.mon) + "." + string(tmp_data_b.day) + " 00:00:01";

    HistorySelect(StringToTime(tmp_x), TimeCurrent());
    int tmp_total = HistoryDealsTotal();
    ulong tmp_ticket = 0;
    double tmp_price;
    double tmp_profit;
    datetime tmp_time;
    string tmp_symboll;
    long tmp_typee;
    long tmp_entry;

    //--- para todos os negócios
    for (tmp_contador = 0; tmp_contador < tmp_total; tmp_contador++)
    {
      //--- tentar obter ticket negócios
      if ((tmp_ticket = HistoryDealGetTicket(tmp_contador)) > 0)
      {
        //--- obter as propriedades negócios
        tmp_price = HistoryDealGetDouble(tmp_ticket, DEAL_PRICE);
        tmp_time = (datetime)HistoryDealGetInteger(tmp_ticket, DEAL_TIME);
        tmp_symboll = HistoryDealGetString(tmp_ticket, DEAL_SYMBOL);
        tmp_typee = HistoryDealGetInteger(tmp_ticket, DEAL_TYPE);
        tmp_entry = HistoryDealGetInteger(tmp_ticket, DEAL_ENTRY);
        tmp_profit = HistoryDealGetDouble(tmp_ticket, DEAL_PROFIT);
        //--- apenas para o símbolo atual
        if (tmp_symboll == Symbol())
          tmp_resultado_financeiro_dia = tmp_resultado_financeiro_dia + tmp_profit;

        if (tmp_resultado_financeiro_dia == 0)
          GanhoMaxDoDia = 0; //se novo dia, zerar a maxima do dia

        if (tmp_resultado_financeiro_dia > GanhoMaxDoDia)
          GanhoMaxDoDia = tmp_resultado_financeiro_dia; //se lucro do dia maior que maxima, atualiza maxima do dia
      }
    }

    if (FinancialLimitEnable)
    {

      if (tmp_resultado_financeiro_dia == 0)
      {

        return (false);
      }
      else
      {
        if (ValorMaximoPerdaDia < (GanhoMaxDoDia - tmp_resultado_financeiro_dia))
        {
          Print("Perda máxima alcançada.");
          return (true);
        }
        else
        {
          if (tmp_resultado_financeiro_dia > MetaGanhoDia)
          {
            Print("Meta Batida.");
            return (true);
          }
        }
      }
      return (false);
    }
    else
      return false;
  }

  double GetLastTransactionProfit()
  {
    datetime end = TimeCurrent();
    datetime start = 0;

    HistorySelect(start, end);
    int total = HistoryOrdersTotal();

    ulong ticket = HistoryOrderGetTicket(total - 1);
    return HistoryDealGetDouble(ticket, DEAL_PROFIT);
  }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
