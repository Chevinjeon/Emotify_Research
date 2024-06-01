import torch
from torch import nn, utils, optim
import numpy as np
import pandas as pd
import os, sys, logging
from tqdm import tqdm

from absl import flags

from data_utils import EEGDataset, idx_to_class
from architecture import Classifier, model_path


FLAGS = flags.FLAGS

flags.DEFINE_integer('batch_size', 4, '')
flags.DEFINE_integer('train_epochs', 100, '')
flags.DEFINE_float('learning_rate', 1e-3, '')
flags.DEFINE_bool('evaluate', False, '')


def train_model():

    train_dataset = EEGDataset()
    train_dataloader = utils.data.DataLoader(train_dataset, batch_size=FLAGS.batch_size, shuffle=False)

    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model = Classifier().to(device)
    optimizer = optim.Adam(model.parameters(), lr=FLAGS.learning_rate)
    loss_fn = nn.CrossEntropyLoss()

    best_epoch_loss = float('inf')
    best_epoch_acc = float('-inf')

    for epoch_idx in range(FLAGS.train_epochs):

        batch_losses = []

        model.train()
        for batch_idx, (batchX, batchY) in tqdm(enumerate(train_dataloader)):
            batchX, batchY = batchX.to(device), batchY.to(device)

            # batchX: [batch size, seq, num channels]

            pred = model(batchX)
            loss = loss_fn(pred, batchY)

            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

            batch_losses.append(loss.detach().numpy())

        epoch_loss = np.mean(batch_losses)
        epoch_acc = evaluate_model(model, test=False)
        
        logging.info(f'completed epoch: {epoch_idx + 1}. average loss: {epoch_loss}, average acc: {epoch_acc}')
        
        torch.save(model.state_dict(), model_path)


def evaluate_model(model, test=True):

    if test is True:
        log_file = 'test_log.txt'
        dataset = EEGDataset(test=True)
    else:
        log_file = 'val_log.txt'
        dataset = EEGDataset(val=True)
    dataloader = utils.data.DataLoader(dataset, batch_size=1, shuffle=False)
    
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    model.to(device)

    total_sample = 0
    correct_sample = 0

    with open(log_file, 'a') as f:
        f.write('NEW ______________________________________________________________________\n\n\n')

    model.eval()
    with torch.no_grad():
        
        for example_idx, (exampleX, exampleY) in tqdm(enumerate(dataloader)):
            exampleX, exampleY = exampleX.to(device), exampleY.to(device)

            pred = model(exampleX).squeeze()
            pred_idx = torch.argmax(pred, dim=0).item()

            label = exampleY.squeeze()
            label_idx = torch.argmax(label, dim=0).item()

            if pred_idx == label_idx:
                correct_sample += 1
            total_sample += 1
            
            with open(log_file, 'a') as f:
                f.write(f'predicted: {idx_to_class[pred_idx]}, actual: {idx_to_class[label_idx]}\n')
            
    return correct_sample / total_sample



if __name__ == '__main__':
    FLAGS(sys.argv)

    logging.basicConfig(level=logging.INFO, format='%(message)s')
    logging.info('process started')

    if FLAGS.evaluate is True:
        model = Classifier()
        model.load_state_dict(torch.load(model_path))

        evaluate_model(model, test=True)
    else:
        train_model()