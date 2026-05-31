import pandas as pd
import yfinance as yf

# 1. 拿到日频的标普500历史收盘价
sp500_daily = yf.download("^GSPC", start="2020-01-01")['Close'].to_frame()

# 2. 读取席勒教授的月频权威数据 (获取里面的 Earnings 列)
shiller_url = "http://www.econ.yale.edu/~shiller/data/ie_data.xls"
df_shiller = pd.read_excel(shiller_url, sheet_name="Data", skiprows=7)

# 整理席勒数据的日期，将其转换为标准日期格式
df_shiller['Date'] = df_shiller['Date'].astype(str).str.replace(r'\.10$', '.12', regex=True) # 修正10月份的小数表示法
df_shiller['Date'] = pd.to_datetime(df_shiller['Date'], format='%Y.%m') + pd.offsets.MonthEnd(0)
df_shiller.set_index('Date', inplace=True)

# 提取每股盈利列 (Earnings 是 E 列，由于 Python 索引从0开始，根据实际表格调整列名或位置)
# 假设席勒表中盈利列名为 'Earnings'
monthly_earnings = df_shiller['Earnings'] 

# 3. 将月频的 Earnings 重采样/前向填充到日频，与日频价格对齐
sp500_daily = sp500_daily.reindex(pd.date_range(start=sp500_daily.index.min(), end=sp500_daily.index.max(), freq='D'))
sp500_daily['Earnings'] = monthly_earnings.reindex(sp500_daily.index).ffill()

# 4. 计算每日 PE = 每日收盘价 / 每日最新滚动的每股盈利
sp500_daily['Daily_PE'] = sp500_daily['Close'] / sp500_daily['Earnings']

# 5. 过滤掉非交易日并导出
sp500_daily.dropna(subset=['Close']).to_csv("sp500_daily_pe_backtest.csv")