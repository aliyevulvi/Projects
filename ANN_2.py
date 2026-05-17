import pandas as pd

df = pd.read_csv(r'C:\Users\Ulvi\Documents\Homeworks\DataMining\anime.csv')

cols_to_drop = ['mal_id', 'title', 'title_english', 'title_japanese', 'image_url', 'rank', 
                'popularity', 'airing', 'duration', 'favorites', 'scored_by', 'members', 'synopsis', 
                'background', 'aired_from', 'aired_to', 'duration', 'studios', 
                'producers', 'licensors', 'themes', 'demographics', 'status']

df.drop(columns=[c for c in cols_to_drop if c in df.columns], inplace=True)

df = df.dropna(subset=['score'])
df = df[df['score'] > 0]
df['target'] = (df['score'] >= 7.5).astype(int)
df.drop(columns=['score'], inplace=True)

df['episodes'] = pd.to_numeric(df['episodes'], errors='coerce')
df['episodes'] = df['episodes'].fillna(df['episodes'].median())

genres_dummies = df['genres'].str.get_dummies(sep='|')
df = pd.concat([df, genres_dummies], axis=1)
df.drop(columns=['genres'], inplace=True)

df = pd.get_dummies(df, columns=['type', 'source', 'rating', 'season'], drop_first=True)



from sklearn.model_selection import train_test_split

X = df.drop('target', axis=1)
y = df['target']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

X_train = X_train.dropna()
y_train = y_train[X_train.index] 

X_test = X_test.dropna()
y_test = y_test[X_test.index]




from sklearn.neural_network import MLPClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report

ann_model_2_layer = MLPClassifier(hidden_layer_sizes=(32, 16), 
                                  activation='relu', 
                                  solver='adam', 
                                  max_iter=500, 
                                  random_state=42)

ann_model_2_layer.fit(X_train, y_train)

y_pred_ann2 = ann_model_2_layer.predict(X_test)

print("--- Artificial Neural Network (2 Hidden Layers) Results ---")
print(f"Accuracy: {accuracy_score(y_test, y_pred_ann2):.4f}")
print("\nClassification Report:\n", classification_report(y_test, y_pred_ann2))

import seaborn as sns
import matplotlib.pyplot as plt

cm_ann2 = confusion_matrix(y_test, y_pred_ann2)
plt.figure(figsize=(7,5))
sns.heatmap(cm_ann2, annot=True, fmt='d', cmap='YlGnBu', 
            xticklabels=['Normal (0)', 'Yüksek Puan (1)'],
            yticklabels=['Normal (0)', 'Yüksek Puan (1)'])
plt.title('2-Layer Neural Network - Confusion Matrix')
plt.show()