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

from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report
import matplotlib.pyplot as plt
from sklearn.tree import plot_tree

gini_tree = DecisionTreeClassifier(criterion='gini', 
                                   max_depth=5, 
                                   random_state=42, 
                                   min_samples_split=20)

from sklearn.model_selection import cross_val_score

cv_scores = cross_val_score(gini_tree, X, y, cv=5)

print(f"Cross-Validation Scores: {cv_scores}")
print(f"Mean CV Score: %{cv_scores.mean()*100:.2f}")

gini_tree.fit(X_train, y_train)

y_pred_gini = gini_tree.predict(X_test)

print("--- Gini Index Decision Tree Results ---")
print(f"Accuracy: {accuracy_score(y_test, y_pred_gini):.4f}")
print("\nClassification Report:\n", classification_report(y_test, y_pred_gini))


import seaborn as sns

cm = confusion_matrix(y_test, y_pred_gini)
plt.figure(figsize=(6,4))
sns.heatmap(cm, annot=True, fmt='d', cmap='Greens')
plt.xlabel('Tahmin Edilen (Predicted)')
plt.ylabel('Gerçek Değer (Actual)')
plt.title('Gini Tree Confusion Matrix')
plt.show()