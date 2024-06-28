import torch
from torch import nn, utils, optim
import numpy as np
import pandas as pd
import os, sys, logging
from tqdm import tqdm

from absl import flags

from architecture import Model
from architecture_v1 import ModelV1
from data_utils import EEGDatasetV1


FLAGS = flags.FLAGS

flags.DEFINE_string('model_path', 'classifier2.pt', '')
eval_result_file = 'evaluation_result.txt'


def evaluate_model(model, test=True):

    dataset = EEGDatasetV1(both=True)
    dataloader = utils.data.DataLoader(dataset, batch_size=1, shuffle=False)
    
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model.to(device)


    model.eval()
    with torch.no_grad():
        
        for example_idx, (exampleX, exampleY) in tqdm(enumerate(dataloader)):
            exampleX, exampleY = exampleX.to(device), exampleY.to(device)

            pred = model(exampleX).squeeze()
            pred_idx = torch.argmax(pred, dim=0).item()

            label = exampleY.squeeze()
            label_idx = torch.argmax(label, dim=0).item()
            
            logging.info(f'sample: predicted {pred_idx}, label {label_idx}')
            
            with open(eval_result_file, 'a') as f:
                f.write(f'sample: predicted {pred_idx}, label {label_idx}\n')
            

if __name__ == '__main__':
    FLAGS(sys.argv)

    logging.basicConfig(level=logging.INFO, format='%(message)s')
    logging.info('evaluation process started')

    model = Model()
    model.load_state_dict(torch.load(FLAGS.model_path))

    evaluate_model(model, test=True)