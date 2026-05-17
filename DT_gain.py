import pandas as pd

df = pd.read_csv(r'C:\Users\Ulvi\Documents\Homeworks\DataMining\anime.csv')

# Data preporcessing removing unnecessary columns, handling missing values, and encoding categorical variables 
cols_to_drop = ['mal_id', 'title', 'title_english', 'title_japanese', 'image_url', 'rank', 
                'popularity', 'airing', 'duration', 'favorites', 'scored_by', 'members', 'synopsis', 
                'background', 'aired_from', 'aired_to', 'duration', 'studios', 
                'producers', 'licensors', 'themes', 'demographics', 'status']

df.drop(columns=[c for c in cols_to_drop if c in df.columns], inplace=True)

# REMOVE MISSING SCORES AND CREATE TARGET
df = df.dropna(subset=['score'])
df = df[df['score'] > 0]
df['target'] = (df['score'] >= 7.5).astype(int) # 7.5 ve üzeri başarılı (1)
df.drop(columns=['score'], inplace=True)


df['episodes'] = pd.to_numeric(df['episodes'], errors='coerce')
df['episodes'] = df['episodes'].fillna(df['episodes'].median())


genres_dummies = df['genres'].str.get_dummies(sep='|')
df = pd.concat([df, genres_dummies], axis=1)
df.drop(columns=['genres'], inplace=True)


df = pd.get_dummies(df, columns=['type', 'source', 'rating', 'season'], drop_first=True)
# DATA PREPROCESSING END



from sklearn.model_selection import train_test_split

X = df.drop('target', axis=1)
y = df['target']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

X_train = X_train.dropna()
y_train = y_train[X_train.index]

X_test = X_test.dropna()
y_test = y_test[X_test.index]

from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import matplotlib.pyplot as plt

print(f"Train Set: {X_train.shape[0]} instance")
print(f"Test Set: {X_test.shape[0]} instance")

gain_tree = DecisionTreeClassifier(max_depth=2, criterion='entropy', random_state=42)

from sklearn.ensemble import AdaBoostClassifier

boosting_tree = AdaBoostClassifier(estimator=gain_tree, 
                                   n_estimators=100, 
                                   learning_rate=0.1, 
                                   random_state=42)

boosting_tree.fit(X_train, y_train)
y_pred = boosting_tree.predict(X_test)

print(f"Gain Ratio Yaklaşımlı Model Başarısı: {accuracy_score(y_test, y_pred):.4f}")
print("\nClassification Report:\n", classification_report(y_test, y_pred))


import seaborn as sns

cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(6,4))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
plt.xlabel('Tahmin Edilen')
plt.ylabel('Gerçek Değer')
plt.title('Gini Tree Confusion Matrix')
plt.show()