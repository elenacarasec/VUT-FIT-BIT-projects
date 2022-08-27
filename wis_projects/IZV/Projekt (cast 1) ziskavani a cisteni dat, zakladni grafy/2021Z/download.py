#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import os
import io
import zipfile
import requests
import csv
from bs4 import BeautifulSoup
import gzip
import pickle
# Kromě vestavěných knihoven (os, sys, re, requests…) byste si měli vystačit s:
# gzip, pickle, csv, zipfile, numpy, matplotlib, BeautifulSoup.
# Další knihovny je možné použít po schválení opravujícím (např ve fóru WIS).


class DataDownloader:
    """
    A class used to download data from a webpage.

    Attributes
    ----------
        headers    Nazvy hlavicek jednotlivych CSV souboru, tyto nazvy nemente!
        regions     Dictionary s nazvy kraju : nazev csv souboru

    Methods
    -------
    download_data():
        Download zip files from the webpage.

    parse_region_data(region):
        Open zip files and return dictionary
        filled in with data from the region.

    get_dict(regions=None):
        Return a dictionary with data from the multiple regions.
    """

    headers = [
        "p1", "p36", "p37", "p2a", "weekday(p2a)", "p2b",
        "p6", "p7", "p8", "p9", "p10", "p11", "p12", "p13a",
        "p13b", "p13c", "p14", "p15", "p16", "p17", "p18", "p19",
        "p20", "p21", "p22", "p23", "p24", "p27", "p28",
        "p34", "p35", "p39", "p44", "p45a", "p47", "p48a",
        "p49", "p50a", "p50b", "p51", "p52", "p53", "p55a",
        "p57", "p58", "a", "b", "d", "e", "f", "g", "h", "i", "j",
        "k", "l", "n", "o", "p", "q", "r", "s", "t", "p5a"
    ]

    regions = {
        "PHA": "00",
        "STC": "01",
        "JHC": "02",
        "PLK": "03",
        "ULK": "04",
        "HKK": "05",
        "JHM": "06",
        "MSK": "07",
        "OLK": "14",
        "ZLK": "15",
        "VYS": "16",
        "PAK": "17",
        "LBK": "18",
        "KVK": "19",
    }

    def __init__(
            self,
            url="https://ehw.fit.vutbr.cz/izv/",
            folder="data",
            cache_filename="data_{}.pkl.gz"):
        """
        Parameters
        ----------
        url : str, optional
            Link to the webpage with data
        folder : str, optional
            Folder name to keep data archives
        cache_filename : str, optional
            File name of cache file
        """

        self.url = url
        self.folder = folder
        self.cache_filename = cache_filename
        self.regions_data_dict = {
            region: None for region in self.regions.keys()
        }

    def download_data(self):
        """Download zip files from the webpage
        and save them to the folder.
        """

        if not os.path.exists(self.folder):
            os.makedirs(self.folder)

        resp = requests.get(self.url)
        html_data = BeautifulSoup(resp.text, "html.parser")
        for link in html_data.find_all("button"):
            url_link = self.url + link["onclick"].split("\'")[1]
            r = requests.get(url_link, stream=True)
            if r.ok:
                filename = url_link.split('/')[-1]
                with open(f"./{self.folder}/{filename}", 'wb') as fd:
                    for chunk in r.iter_content(chunk_size=1024):
                        fd.write(chunk)
            else:
                print('Error in downloading data\n')
                exit(1)

    def parse_region_data(self, region):
        """Open zip files and return dictionary
        filled in with data from the region.

        Parameters
        ----------
        region : str
            The region to parse

        Returns
        -------
        dict
            a dict representing dataframe
            with headers as keys and np.ndarray() as values.
        """

        if not os.path.exists(self.folder) or not os.listdir(self.folder):
            self.download_data()

        if region not in self.regions:
            print("Undefined region code\n")
            exit(1)

        data_types = [
            "i8", "i8", "i8", "M", "i8", "i8", "i8", "i8", "i8", "i8",
            "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8",
            "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8",
            "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8", "i8",
            "i8", "i8", "i8", "i8", "i8", "f", "f", "f", "f", "f",
            "f", "U16", "U16", "U16", "U16", "U16", "U16", "U16", "U16", "U16",
            "i8", "i8", "U16", "i8"
        ]

        datadict = {hdr: [] for hdr in self.headers}
        for archivfile in os.listdir(self.folder):
            try:
                with zipfile.ZipFile(f"{self.folder}/{archivfile}", 'r') as zf:
                    with zf.open(
                            f'{self.regions[region]}.csv', 'r') as csv_file:
                        reader = csv.reader(
                            io.TextIOWrapper(csv_file, "cp1250"),
                            delimiter=';')
                        for row in reader:
                            for idx, cell in enumerate(row):
                                if data_types[idx] == 'f':
                                    cell = cell.replace(',', '.')
                                if cell in [
                                        '', 'XX', 'A:', 'B:', 'C:',
                                        "D:", "E:", "F:", "G:"
                                        ]:
                                    cell = -1

                                datadict[self.headers[idx]].append(cell)
                        zf.close()
            except zipfile.BadZipFile:
                pass

        data_types_dict = dict(zip(self.headers, data_types))
        for key in datadict:
            datadict[key] = np.array(datadict[key], dtype=data_types_dict[key])

        datadict['region'] = np.full(len(datadict[self.headers[0]]), region)

        return datadict

    def get_dict(self, regions=None):
        """Return a dictionary with data from the multiple regions.

        Parameters
        ----------
        regions : list, optional
            The list of regions to parse,
            default(None) is equal to all regions.

        Returns
        -------
        dict
            a dict representing dataframe with data from regions
            with headers as keys and np.ndarray() as values.
        """
        if regions is None or regions == []:
            regions = self.regions.keys()

        reg_data_table_list = []
        for region in regions:
            # if data are in memory
            if(self.regions_data_dict[region] is not None):
                region_dict = self.regions_data_dict[region]
            # if data are cached
            elif(os.path.exists(
                    self.folder + '/' + self.cache_filename.format(region))):
                with gzip.open(
                        self.folder + '/' + self.cache_filename.format(region),
                        'r') as cache_file:
                    region_dict = pickle.load(cache_file)
                    cache_file.close()
                self.regions_data_dict[region] = region_dict
            # if data are neither in memory nor cached
            else:
                region_dict = self.parse_region_data(region)
                self.regions_data_dict[region] = region_dict
                with gzip.open(
                        self.folder + '/' + self.cache_filename.format(region),
                        'w') as cache_file:
                    pickle.dump(region_dict, cache_file)
                    cache_file.close()

            reg_data_table_list.append(region_dict)

        reg_data_dict = reg_data_table_list[0]
        for reg_data_table in reg_data_table_list[1:]:
            for key in self.headers:
                reg_data_dict[key] = np.append(
                                        reg_data_dict[key],
                                        reg_data_table[key]
                )
            reg_data_dict['region'] = np.append(
                                        reg_data_dict['region'],
                                        reg_data_table['region']
            )

        return reg_data_dict


if __name__ == "__main__":
    ddwnld = DataDownloader()

    regions = ["PHA", "JHM", "JHC"]
    data = ddwnld.get_dict(regions)

    if regions is None or regions == []:
        regions = ddwnld.regions.keys()
    print("Regions parsed: ", ', '.join(regions))
    print("Columns: ", len(data.keys()))
    print("Rows: ", len(list(data.values())[0]))

# TODO vypsat zakladni informace pri spusteni
# python3 download.py (ne pri importu modulu)
