#!/usr/bin/env python3.9
# coding=utf-8
from matplotlib import pyplot as plt
import pandas as pd
import seaborn as sns
import numpy as np
import os

# muzete pridat libovolnou zakladni knihovnu ci knihovnu predstavenou na prednaskach
# dalsi knihovny pak na dotaz

""" Ukol 1:
načíst soubor nehod, který byl vytvořen z vašich dat. Neznámé integerové hodnoty byly mapovány na -1.

Úkoly:
- vytvořte sloupec date, který bude ve formátu data (berte v potaz pouze datum, tj sloupec p2a)
- vhodné sloupce zmenšete pomocí kategorických datových typů. Měli byste se dostat po 0.5 GB. Neměňte však na kategorický typ region (špatně by se vám pracovalo s figure-level funkcemi)
- implementujte funkci, která vypíše kompletní (hlubkou) velikost všech sloupců v DataFrame v paměti:
orig_size=X MB
new_size=X MB

Poznámka: zobrazujte na 1 desetinné místo (.1f) a počítejte, že 1 MB = 1e6 B. 
"""


def get_dataframe(filename: str, verbose: bool = False) -> pd.DataFrame:
    df = pd.read_pickle(filename)
    orig_size = df.memory_usage(deep=True).sum() / 1048576
    orig_size = '{0:.1f}'.format(orig_size)
    df['date'] = pd.to_datetime(df['p2a'], format='%Y-%m-%d')
    df = df.drop(columns=['p2a'])

    df[['k', 'p', 'q', 't']] = df[['k', 'p', 'q', 't']].astype('category')

    if verbose:
        new_size = df.memory_usage(deep=True).sum() / 1048576
        new_size = '{0:.1f}'.format(new_size)
        print(f'orig_size = {orig_size} MB')
        print(f'new_size = {new_size} MB')
    return df

# Ukol 2: počty nehod v jednotlivých regionech podle druhu silnic

def plot_roadtype(df: pd.DataFrame, fig_location: str = None,
                  show_figure: bool = False):
    komunikace_df = df.loc[df.region.isin(['PHA', 'JHM', 'JHC', 'STC'])] 
    komunikace_df = komunikace_df[['region', 'p21']]
    categories = {
        1: 'dvoupruhovy',
        2: 'tripruhovy',
        3: 'ctyrpruhovy',
        4: 'cyrpruhovy',
        5: 'vicepruhovy',
        6: 'rychlostni',
        0: 'jina'
    }

    komunikace_df['p21new'] = komunikace_df['p21'].apply()
    print(komunikace_df.loc[komunikace_df.p21.isin([3, 4])])

    # f = plt.figure(figsize=(6, 6))
    # gs = f.add_gridspec(3, 2)

    # ax = f.add_subplot(gs[0, 0])
    # ax = f.add_subplot(gs[0, 1])
    # ax = f.add_subplot(gs[0, 2])
    # ax = f.add_subplot(gs[1, 0])
    # ax = f.add_subplot(gs[1, 1])
    # ax = f.add_subplot(gs[1, 2])

    # if show_figure:
    #     plt.show_figure()

    pass

# Ukol3: zavinění zvěří
def plot_animals(df: pd.DataFrame, fig_location: str = None,
                 show_figure: bool = False):
    pass

# Ukol 4: Povětrnostní podmínky
def plot_conditions(df: pd.DataFrame, fig_location: str = None,
                    show_figure: bool = False):
    pass

if __name__ == "__main__":
    # zde je ukazka pouziti, tuto cast muzete modifikovat podle libosti
    # skript nebude pri testovani pousten primo, ale budou volany konkreni ¨
    # funkce.
    df = get_dataframe("accidents.pkl.gz", verbose=True) # tento soubor si stahnete sami, při testování pro hodnocení bude existovat
    plot_roadtype(df, fig_location="01_roadtype.png", show_figure=True)
    # plot_animals(df, "02_animals.png", True)
    # plot_conditions(df, "03_conditions.png", True)
