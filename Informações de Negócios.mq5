//+------------------------------------------------------------------+
//|                                      Informações de Negócios.mq5 |
//|                                                  Rafael Fenerick |
//|                           https://www.youtube.com/RafaelFenerick |
//|                                    rafaelfenerick.mql5@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Rafael Fenerick"
#property link      "rafaelfenerick.mql5@gmail.com"
#property version   "1.00"

/*
EA tutorial para coleta e tratamento de informações provindas
do histórico de negócios e do livro de ofertas
*/

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   // Fornece a abertura da Profundidade de Mercado (DOM) para um ativo selecionado,
   // e subscreve para receber notificados de alterações na DOM (Depth of Market).
   // Em caso de erro, impede a inicialização do EA.
   if(!MarketBookAdd(_Symbol))
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   //Fornece o fechamento da Profundidade de Mercado (DOM) para um ativo selecionado, 
   // e cancela a subscrição para receber notificações de alteração na DOM (Depth of Market).
   MarketBookRelease(_Symbol);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   // A função obtém, dentro da matriz ticks_array, ticks no formato MqlTick, além disso a 
   // indexação é realizada do passado para o presente, ou seja, o tick com índice 0 é o 
   // mais antigo na matriz. Para a análise de ticks, é necessário verificar o campo flags, 
   // que indica o que foi alterado nesse tick. Em caso de erro, impede a continuação
   // do evento.
   MqlTick ticks[];
   if(CopyTicks(_Symbol, ticks, COPY_TICKS_TRADE, 0, 100)!=100)
      return;
   
   // Nessa função, vamos varrer os últimos 100 negócios e contar quantos são agressóes de
   // compra, quantos são agressão de venda e quantos são casados. Para tal, vamos verificar
   // as flags dos ticks. Os ticks com agressão de compra têm a flag BUY e não tem a flag
   // SELL. Os ticks com agressão de venda tem a flag SELL e não têm a flag SELL. Os ticks
   // casados, por fim, têm ambas as flags.
   
   int count_buy = 0;
   int count_sell = 0;
   int count_casados = 0;
   
   for(int i=0; i<ArraySize(ticks); i++)
     {
      if((ticks[i].flags&TICK_FLAG_BUY)!=0 && (ticks[i].flags&TICK_FLAG_SELL)==0) count_buy ++;
      if((ticks[i].flags&TICK_FLAG_BUY)==0 && (ticks[i].flags&TICK_FLAG_SELL)!=0) count_sell ++;
      if((ticks[i].flags&TICK_FLAG_BUY)!=0 && (ticks[i].flags&TICK_FLAG_SELL)!=0) count_casados ++;
     }
  
   // Exibir informações desejadas no canto superior esquerdo do gráfico na forma de comentário.
   Comment(StringFormat("\n\nNegócios de compra: %d\nNegócios de venda: %d\n Negócios casados: %d", count_buy, count_sell, count_casados));
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
   // Retorna um array de estruturas MqlBookInfo contendo registros da Profundidade 
   // de Mercado de um ativo especificado. Em caso de erro, impede a continuação
   // do evento.
   MqlBookInfo book[];
   if(!MarketBookGet(_Symbol, book)) 
      return;
      
   // Nessa função, vamos verificar o preço e o volume de ofertas nos níveis de BID e
   // de ASK. Para isso, vamos varrer o book de ofertas do valor mais alto até o valor
   // mais baixo. O nível de ASK será o último do book de SELL e o nível de BID será
   // o primeiro do book de BUY. Dessa forma, a lógica vai decorrer como implementado
   // abaixo.
   
   double ask, bid;
   long ask_volume, bid_volume;
   
   for(int i=0; i<ArraySize(book); i++)
     {
      if(book[i].type==BOOK_TYPE_SELL)
        {
         ask = book[i].price;
         ask_volume = book[i].volume;
        }
      else
        {
         bid = book[i].price;
         bid_volume = book[i].volume;
         break;
        }
     }

   // Exibir informações desejadas no canto superior esquerdo do gráfico na forma de comentário.
   //Comment(StringFormat("\n\nAsk: %.0f\nAsk volume: %d\n\nBid: %.0f\nBid volume: %d", ask, ask_volume, bid, bid_volume));
  }
//+------------------------------------------------------------------+
