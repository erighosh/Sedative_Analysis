__author__ = 'Erina Ghosh'

"""
Implementing module for extracting all medications from MIMIC,
filtering for selected (pain) medications administered in a
given time period and calculating 12 hour shift totals
"""

from sqlalchemy import or_, and_, func
from sqlalchemy.orm import sessionmaker
import json
import pandas as pd
from datetime import datetime, timedelta, time
import warnings
from bson import json_util
import numpy as np
from scipy import io
import sys
import os

from sqlalchemy.orm import create_session
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, DateTime, Float, ForeignKey
from sqlalchemy import create_engine, MetaData, Table, func

import logging
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# INSERT DATABASE CONNECTION PATH BELOW
db_conn_str = ' '
Base = declarative_base()
engine = create_engine(db_conn_str,echo=False)
metadata = MetaData(bind=engine, schema='mimiciii')
session = create_session(bind=engine)

#Definining MIMIC tables
class admissions(Base):
    __table__ = Table('admissions', metadata, autoload = True)

class d_items(Base):
    __table__ = Table('d_items', metadata, autoload = True)

class inputevents_mv(Base):
    __table__ = Table('inputevents_mv', metadata, autoload=True)

class icustays(Base):
    __table__ = Table('icustays', metadata, autoload = True)

class patients(Base):
    __table__ = Table('patients', metadata, autoload = True)


class PainMedETL(object):
    """
    Module defines queries extract pain medications for given ICU Stay ID
    filters for medications of interest and analyzes data
    """

    def __init__(self):
        pain_med_code_df = pd.read_csv('pain_med_list.csv')
        self._pain_med_code_dict = pain_med_code_df.set_index('itemid')['label'].to_dict()
        self._pain_med_type = {'bz': [221385, 221623, 221668],
                               'nbz': [221712, 221824, 225156],
                               'op': [221744, 221833, 222168, 225972, 225973, 225942, 225154]}
        # Equivalency dictionaries
        self._bz_eq_dict = {'Lorazepam (Ativan)': 1, 'Diazepam (Valium)': 5, 'Midazolam (Versed)': 2}
        self._op_eq_dict = {'Fentanyl': 0.01, 'Hydromorphone (Dilaudid)': 0.2,
                            'Fentanyl (Concentrate)': 0.01, 'Morphine Sulfate': 1}

    def get_med_data(self, hadm_id):
        """Function to extract medication data for given ICU Stay ID

        Function extracts med
        :params: |icustay_id| Integer ICU Stay ID
        :return: |Dataframe| containing pain medication administration information
        """

        pat_inp_evs = session.query(inputevents_mv.row_id.label('Row_Num'), inputevents_mv.subject_id.label('SubjectID'),
                                    inputevents_mv.hadm_id.label('Hosp_AdmID'), inputevents_mv.icustay_id.label('ICU_StayID'),
                                    inputevents_mv.itemid.label('ItemID'), inputevents_mv.starttime.label('Start_Time'),
                                    inputevents_mv.endtime.label('End_Time'), inputevents_mv.amount.label('Amount'),
                                    inputevents_mv.rate.label('Rate'), inputevents_mv.rateuom.label('Rate_UOM'),
                                    inputevents_mv.ordercategoryname.label('OrderCategoryName'), inputevents_mv.orderid.label('OrderID'),
                                    inputevents_mv.linkorderid.label('Link_OrderID'), inputevents_mv.patientweight.label('Pt_Weight'),
                                    inputevents_mv.statusdescription.label('Status_Description'), inputevents_mv.amountuom.label('Amount_UOM'),
                                    d_items.label.label('Label'), d_items.category.label('Category')).\
            join(d_items, d_items.itemid == inputevents_mv.itemid).filter(inputevents_mv.hadm_id == hadm_id)

        pat_inp_df = pd.read_sql(pat_inp_evs.statement, pat_inp_evs.session.bind)

        # Filtering for selected meds
        if pat_inp_df.shape[0] > 0:
            for ind, row in pat_inp_df.iterrows():
                if row['ItemID'] in self._pain_med_code_dict:
                    pat_inp_df.ix[ind, 'Med_Name'] = self._pain_med_code_dict[row['ItemID']]
                    # pat_inp_df.ix[ind, 'Med_type'] = [k if row['ItemID'] in v else np.nan
                    #                                   for k, v in self._pain_med_type.iteritems()]
                    # pat_inp_df.ix[ind, 'Med_type'] = \
                    #     list(self._pain_med_type.keys())[list(self._pain_med_type.values()).index(row['ItemID'])]
                else:
                    pat_inp_df.ix[ind, 'Med_Name'] = np.NaN
                    #pat_inp_df.ix['Med_type'] = np.nan

            pat_inp_df = pat_inp_df.dropna(axis=0, how='any', subset=['Med_Name'])

        return pat_inp_df

    def filter_by_duration(self, med_data, starttime, endtime):
        """Function filters medication events for duration of ventilation

        :param med_data: |DataFrame| containing all medication events for a given subject
        :param starttime: |Timestamp| start of ventilation
        :param endtime: |Timestamp| end of ventilation
        :return:|Dataframe| containing rows corresponding to rows for medication during ventilation
        """

        med_data['In_timeframe'] = np.NaN
        for ind, row in med_data.iterrows():
            if (row['Start_Time'] > starttime) and (row['End_Time'] < endtime):
                med_data.ix[ind, 'In_timeframe'] = 1
            elif (row['End_Time'] > starttime) and (row['End_Time'] < endtime):
                med_data.ix[ind, 'In_timeframe'] = 1
            elif (row['Start_Time'] > starttime) and (row['Start_Time'] < endtime):
                med_data.ix[ind, 'In_timeframe'] = 1
            else:
                med_data.ix[ind, 'In_timeframe'] = np.NaN

        med_data = med_data.dropna(axis=0, how='any', subset=['In_timeframe'])
        #del med_data['In_timeframe']

        return med_data


    def _shift_start_time(self, med_time):
        """Function returns the start of shift time for the given time.

        :param med_time: |Timestamp| for medication administration or IV start or end
        :return: |Timestamp| of shift start
        """
        if med_time.hour > 7 and med_time.hour <= 19:
            starttime = med_time - timedelta(hours=med_time.hour - 7) - timedelta(minutes=med_time.minute)
        elif med_time.hour > 19:
            starttime = med_time - timedelta(hours=med_time.hour - 19) - timedelta(minutes=med_time.minute)
        else:
            starttime = med_time - timedelta(hours=med_time.hour + 5) - timedelta(minutes=med_time.minute)
        return starttime

    def _shift_end_time(self, med_time):
        """Function returns the end of shift time for the given time.

        :param med_time: |Timestamp| for medication administration or IV start or end
        :return: |Timestamp| of shift end
        """
        if med_time.hour > 7 and med_time.hour <= 19:
            endtime = med_time + timedelta(hours=19 - med_time.hour) - timedelta(minutes=med_time.minute)
        elif med_time.hour > 19:
            endtime = med_time + timedelta(hours=31 - med_time.hour) - timedelta(minutes=med_time.minute)
        else:
            endtime = med_time + timedelta(hours=7 - med_time.hour) - timedelta(minutes=med_time.minute)
        return endtime

    def _shift_IV_amt(self, start, end):
        """Function returns distribution of IV med dose over shifts

        Considers 3 cases:
        Case 1: the whole drug is given in a single shift.
        Case 2: the drug is given over 2 consecutive shifts.
        Case 3: the drug is given over more than 2 shifts.

        :param start: |Timestamp| of IV drug start
        :param end: |Timestamp| of IV drug end
        :return: |List| of medication amount divided by shifts
        """
        start_shift_start = self._shift_start_time(start)
        start_shift_end = self._shift_end_time(start)
        end_shift_start = self._shift_start_time(end)
        end_shift_end = self._shift_end_time(end)
        # Case 1: All drug within a shift
        if start_shift_start == end_shift_start and start_shift_end == end_shift_end:
            return [end - start]
        # Case 2: Drug given in consecutive shifts
        elif start_shift_end == end_shift_start:
            return [start_shift_end - start, end - end_shift_start]
        # Case 3: Drug given over more than 2 shifts
        else:
            drug_dur_shift = int(((end_shift_start - start_shift_end).total_seconds()) / 43200)
            dur_list = [start_shift_end - start, end - end_shift_start]
            for i in range(drug_dur_shift):
                dur_list.insert(1, 12)
            return dur_list

    def get_bolus_shift_total(self, med_data):
        """Function gets dataframe of bolus medications and returns shiftwise sum of drug doses
        Shifts start at 7 AM and 7 PM. All dose for the shift are indicated by the start time
        of shift

        :param med_data: |Dataframe| containing bolus medications only
        :return: |Dataframe| Unstacked dataframe containing total dose of each medication over a shift
        """

        med_data.loc[med_data['Amount_UOM'] == 'mcg', 'norm_amount'] = med_data['Amount']/1000
        med_data['norm_amount'] = med_data['norm_amount'].fillna(value = med_data['Amount'])
        med_data_subset = med_data[['End_Time','Label', 'norm_amount']].copy()
        med_data_subset = med_data_subset.groupby(['End_Time', 'Label']).mean()
        med_data_unstack = med_data_subset.unstack()
        med_data_unstack.columns = med_data_unstack.columns.droplevel()

        med_data_hourly = med_data_unstack.resample(rule='1H', how='sum', label='right')
        for i in range(med_data_hourly.shape[0]):
            med_data_hourly.ix[i, 'Shift_Start'] = self._shift_start_time(med_data_hourly.index[i])

        bolus_shift_total = med_data_hourly.groupby(['Shift_Start']).sum()

        return bolus_shift_total

    def get_IV_shift_total(self, med_data):
        """Function gets dataframe of IV medications and returns shiftwise sum of drug doses
        Shifts start at 7 AM and 7 PM. All dose for the shift are indicated by the start time
        of shift

        :param med_data: |Dataframe| containing bolus medications only
        :return: |Dataframe| Unstacked dataframe containing total dose of each medication over a shift
        """

        # Correcting units
        med_data['norm_rate'] = np.nan
        med_data.loc[med_data['RATEUOM'] == 'mcg/hour', 'norm_rate'] = med_data['RATE'] / 1000
        med_data.loc[med_data['RATEUOM'] == 'mcg/kg/hour', 'norm_rate'] = \
            med_data['RATE'] * med_data['PATIENTWEIGHT'] / 1000
        med_data.loc[med_data['RATEUOM'] == 'mcg/kg/min', 'norm_rate'] = \
            med_data['RATE'] * med_data['PATIENTWEIGHT'] * 60 / 1000
        med_data['norm_rate'] = med_data['norm_rate'].fillna(value=med_data['RATE'])

        med_data_IV = med_data[['Start_Time','End_Time','Label', 'norm_rate']].copy()
        med_data_IV['duration'] = med_data_IV['End_Time'] - med_data_IV['Start_Time']

        iv_drug_shift = pd.DataFrame(columns = ['Shift_Start', 'label', 'amount(mg)'])
        for i, r in med_data_IV.iterrows():
            dose_break = self._shift_IV_amt(r['Start_Time'], r['End_Time'])
            # Creating a dataframe with rows = dose break rows
            a = pd.DataFrame(columns = ['Shift_Start', 'label', 'amount(mg)'])

            if len(dose_break) < 2:
                shift_start_times = [self._shift_start_time(r['Start_Time'])]
            elif len(dose_break) == 2:
                shift_start_times = [self._shift_start_time(r['Start_Time']), self._shift_start_time(r['End_Time'])]
            else:
                shift_start_times = [self._shift_start_time(r['Start_Time']), self._shift_start_time(r['End_Time'])]
                for j in range(1, len(dose_break)-1):
                    shift_start_times.insert(j, shift_start_times[j-1] + timedelta(hours = 12))

            a['Shift_Start'] = shift_start_times

            amount = []
            for j in range(len(dose_break)):
                if type(dose_break[j]) == int:
                    amount.append(r['norm_rate'] * (dose_break[j]))
                else:
                    amount.append(r['norm_rate'] * (dose_break[j].total_seconds()/3600))
            a['amount(mg)'] = amount
            a['label'] = r['Label']

            iv_drug_shift = pd.concat([iv_drug_shift, a])

        iv_drug_to_unstack = iv_drug_shift.groupby(['Shift_Start', 'label']).mean()
        iv_drug_shift_df = iv_drug_to_unstack.unstack()
        iv_drug_shift_df.columns = iv_drug_shift_df.columns.droplevel()

        return iv_drug_shift_df

    def get_patient_by_med(self, drug_id, subj_list):
        """Function returns a list of patient IDs who received the specified drug

        :param drug_id: |Integer| SNOMED code for drug ID
        :param subj_list: |List| of patient IDs included in cohort
        """

        med_inp_evs = session.query(inputevents_mv.row_id.label('Row_Num'), inputevents_mv.subject_id.label('SubjectID'),
                                    inputevents_mv.hadm_id.label('Hosp_AdmID'), inputevents_mv.icustay_id.label('ICU_StayID'),
                                    inputevents_mv.itemid.label('ItemID'), inputevents_mv.starttime.label('Start_Time'),
                                    inputevents_mv.endtime.label('End_Time'), inputevents_mv.amount.label('Amount'),
                                    inputevents_mv.rate.label('Rate'), inputevents_mv.rateuom.label('Rate_UOM'),
                                    inputevents_mv.ordercategoryname.label('OrderCategoryName'), inputevents_mv.orderid.label('OrderID'),
                                    inputevents_mv.linkorderid.label('Link_OrderID'), inputevents_mv.patientweight.label('Pt_Weight'),
                                    inputevents_mv.statusdescription.label('Status_Description'), inputevents_mv.amountuom.label('Amount_UOM'),
                                    d_items.label.label('Label'), d_items.category.label('Category')).\
            join(d_items, d_items.itemid == inputevents_mv.itemid).filter(inputevents_mv.itemid == drug_id)

        med_inp_df = pd.read_sql(med_inp_evs.statement, med_inp_evs.session.bind)

        for i, r in med_inp_df.iterrows():
            if r['Hosp_AdmID'] in subj_list:
                med_inp_df.ix[i,'Keep'] = 1
            else:
                med_inp_df.ix[i,'Keep'] = np.nan

        med_inp_df = med_inp_df.dropna(how='any', subset=['Keep'], axis=0)
        return med_inp_df

    def get_pt_drug_type(self, med_data):
        """Function to calculate categories of drugs given to subject

        :param med_data: |Dataframe| containing medication events for given subject
        :return: |Dictionary| with binary indication of drug categories given
        """
        # Grouping by med type
        bz_med = med_data.loc[med_data['Med_type'] == 'bz']
        nbz_med = med_data.loc[med_data['Med_type'] == 'nbz']
        op_med = med_data.loc[bz_med['Med_type'] == 'op']

        bz_flag = [1 if bz_med.shape[0] > 0 else 0]
        nbz_flag = [1 if nbz_med.shape[0] > 0 else 0]
        op_flag = [1 if op_med.shape[0] > 0 else 0]

        return {'BZ': bz_flag, 'NBZ': nbz_flag, 'OP' : op_flag}

    def get_all_pt_med_type(self, sub_list):
        """Function to get all drug categories for all subjects

        :param sub_list: |List| of subject IDs
        :return: |Dataframe| with binary flags indicating drug types administered
        """

        for i in sub_list:
            med_data = self.get_med_data(i)
            med_vent_data = self.filter_by_duration()