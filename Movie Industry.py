#!/usr/bin/env python
# coding: utf-8

# In[23]:


# Import Libraries

import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8) #Adjusts the configuration of plots

# Read in the data

df = pd.read_csv(r'C:\Users\Jake\Downloads/movies.csv')


# In[24]:


# Let's look at the data

df.head()


# In[9]:


# Checking for any missing data

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, pct_missing))


# In[10]:


# Data types of the columns

df.dtypes


# In[33]:


# Changing the data type of columns; budget and gross

df['budget'] = pd.to_numeric(df['budget'], errors='coerce').fillna(0).astype(int)

df['gross'] = pd.to_numeric(df['gross'], errors='coerce').fillna(0).astype(int)


# In[68]:


#Create correct year column

df['yearcorrect'] = df['released'].astype(str).str[:4]

df.head()


# In[31]:


df.sort_values(by=['gross'], inplace=False, ascending=False)


# In[32]:


pd.set_option('display.max_rows', None)


# In[33]:


# Drop any duplicates

df['company'].drop_duplicates().sort_values(ascending=False)


# In[69]:


df.head()


# In[ ]:


# Null Hypothesis (H-0): High correleation between budget and company

# Alernative Hypothesis (H-1): No/little correlation between budget and company


# In[37]:


#Scatter Plot with budget vs gross


plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget Earnings')

plt.show()


# In[36]:


df.head()


# In[39]:


# Plot the budget vs gross using seaborn


sns.regplot(x='budget', y='gross', data=df, scatter_kws={"color": "red"}, line_kws={"color": "blue"})


# In[53]:


# Correlation

df.corr(numeric_only = [False])


# In[ ]:


# There is high correlation between budget and gross.


# In[55]:


correlation_matrix = df.corr(numeric_only = [False])

sns.heatmap(correlation_matrix, annot=True)

plt.title('Correlation Matric for Numeric Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')




plt.show()


# In[56]:


# Look at Company

df.head()


# In[70]:


df_numerized = df

for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes
        
        
df_numerized.head()        


# In[58]:


correlation_matrix = df_numerized.corr(numeric_only = [False])

sns.heatmap(correlation_matrix, annot=True)

plt.title('Correlation Matric for Numeric Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')

plt.show()


# In[59]:


df_numerized.corr()


# In[60]:


correlation_mat = df_numerized.corr()

corr_pairs = correlation_mat.unstack()

corr_pairs


# In[62]:


sorted_pairs = corr_pairs.sort_values()

sorted_pairs


# In[67]:


high_corr = sorted_pairs[(sorted_pairs) > 0.5]

high_corr


# In[ ]:


# Votes and Budget have the highest correlation to gross earnings.

# Budget and Company have little correlation.
# Reject the Null Hypothesis and accept the Alternative Hypothesis.

