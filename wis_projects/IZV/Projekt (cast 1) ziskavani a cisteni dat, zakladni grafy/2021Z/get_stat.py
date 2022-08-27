#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from os import name
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.colors import LogNorm
import argparse
# povolene jsou pouze zakladni knihovny (os, sys)
# a knihovny numpy, matplotlib a argparse

from download import DataDownloader


def get_data_for_graph(data_source):
    """Get the necessary data from the dataframe and calculate statistics.

    Parameters
    ----------
    data_source : dict
        The dictionary with data about the regions.

    Returns
    -------
    list
        a list of strings representing parsed regions.
    np.ndarray
        array with absolute statistical values.
    np.ndarray
        array with relative statistical values (percentages).
    """
    regions_changes = np.array([data_source["region"], data_source["p24"]])
    changes_dict = {}
    regions = np.unique(regions_changes[0])
    for region in regions:
        mask = np.where(regions_changes[0] == region)
        changes_dict[region] = np.ndarray.flatten(regions_changes[1, mask])

    default_stats = {str(x): 0 for x in np.append(np.arange(1, 6), 0)}
    global_count = []
    for region in changes_dict:
        val, count = np.unique(changes_dict[region], return_counts=True)
        stats = dict(zip(val, count))
        def_stats = default_stats.copy()
        def_stats.update(stats)
        count = np.array(list(def_stats.values()))
        global_count = np.append(global_count, count)

    global_count = np.transpose(global_count.reshape(-1, 6))
    global_stats = np.divide(
                        global_count * 100,
                        np.sum(global_count, axis=1)[:, None]
    )
    global_count_bad = np.where(global_count == 0, np.nan, global_count)
    global_stats_bad = np.where(global_stats == 0, np.nan, global_stats)

    return regions, global_count_bad, global_stats_bad


def subgraph_setup(
        ax, fig, data_array, regions,
        colormap="viridis", norm=None, title="", label=""):
    """Prepare subgraph.

    Parameters
    ----------
    ax : axes.Axes object
    fig : matplotlib.pyplot.figure object
    data_array : np.ndarray
        Array with absolute statistical values.
    regions : list
        List of parsed regions.
    colormap : str, optional
        A Colormap instance name, "viridis" by default.
    norm : class, optional
        LogNorm class for logarithmic scale, linear by default.
    title : str, optional
        Subgraph title.
    label : str, optional
        Colorbar label.
    """

    changes = [
        "Přerušovaná žluta",
        "Semafor mimo provoz",
        "Dopravnimí značky",
        "Přenosné dopravní značky",
        "Nevyznačená",
        "Žádná úprava"
    ]

    ax.set_title(title)
    cmap = cm.get_cmap(colormap).copy()
    img = ax.imshow(data_array, cmap=cmap, norm=norm)
    ax.set_xticks(np.arange(len(regions)))
    ax.set_yticks(np.arange(len(changes)))
    ax.set_xticklabels(regions)
    ax.set_yticklabels(changes)
    cbar = fig.colorbar(img, ax=ax, label=label, shrink=0.4)
    cbar.cmap.set_bad('white')


def plot_stat(data_source,
              fig_location=None,
              show_figure=False):
    """Plot the graph with statistics from the regions

    Parameters
    ----------
    data_source : dict
        The dictionary with data about the regions.
    fig_location : str, optional
        Path to the file, where the graph will be stored.
        Does not save the file by default.
    show_figure : bool, optional
        Displays figure with the graph if True.
        Does not display by default.
    """
    regions, count, stats = get_data_for_graph(data_source)

    fig, (ax1, ax2) = plt.subplots(figsize=(8, 11), nrows=2)

    subgraph_setup(
            ax1, fig, count, regions,
            norm=LogNorm(vmin=10**0, vmax=10**6),
            title="Absolutně",
            label="Počet nehod"
    )

    subgraph_setup(
            ax2, fig, stats, regions,
            colormap="plasma",
            title="Relativně vůči příčině",
            label="Podíl nehod pro danou příčinu [%]"
    )

    fig.tight_layout()
    plt.plot()

    if fig_location:
        (dirname, filename) = os.path.split(fig_location)
        if dirname and not os.path.exists(dirname):
            os.makedirs(dirname)
        plt.savefig(fig_location, format='pdf')

    if show_figure:
        plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--fig_location',
                        dest="fig_location",
                        help='Path for figure location')
    parser.add_argument('--show_figure',
                        dest="show_fig",
                        action="store_true",
                        help='Show plot')
    args = parser.parse_args()

    regions = []
    data_source = DataDownloader().get_dict(regions)
    plot_stat(
        data_source,
        fig_location=args.fig_location,
        show_figure=args.show_fig
    )


# TODO pri spusteni zpracovat argumenty
