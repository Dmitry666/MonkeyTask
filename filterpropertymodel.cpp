#include "filterpropertymodel.h"
#include <QDebug>

FilterPropertyModel::FilterPropertyModel(QObject *parent)
    : QAbstractListModel(parent)
    , _sourceModel(nullptr)
{}

int FilterPropertyModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return _items.count();
}

QVariant FilterPropertyModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= rowCount()) {
        return QVariant();
    }

    int actualIndex = _items[index.row()];
    auto actualModelIndex = _sourceModel->index(actualIndex, 0);

    return _sourceModel->data(actualModelIndex, role);
}

bool FilterPropertyModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.row() < 0 || index.row() >= rowCount()) {
        return false;
    }

    int actualRequestedIndex = _items[index.row()];

    QModelIndex adjustedModelIndex = _sourceModel->index(actualRequestedIndex, 0);
    return _sourceModel->setData(adjustedModelIndex, value, role);
}

QHash<int, QByteArray> FilterPropertyModel::roleNames() const
{
    return _sourceModel != nullptr ? _sourceModel->roleNames() : QHash<int, QByteArray>();
}

void FilterPropertyModel::setSourceModel(QAbstractItemModel* value)
{
    if (_sourceModel != nullptr) {
        disconnect(_sourceModel, SIGNAL(dataChanged(QModelIndex, QModelIndex, QVector<int>)), this, SLOT(updateItems()));
        disconnect(_sourceModel, SIGNAL(rowsInserted(QModelIndex, int, int)), this, SLOT(updateItems()));
        disconnect(_sourceModel, SIGNAL(rowsRemoved(QModelIndex, int, int)), this, SLOT(updateItems()));
    }

    _sourceModel = value;
    emit sourceModelChanged(value);
    updateItems();

    if (_sourceModel != nullptr) {
        connect(_sourceModel, SIGNAL(dataChanged(QModelIndex, QModelIndex, QVector<int>)), this, SLOT(updateItems()));
        connect(_sourceModel, SIGNAL(rowsInserted(QModelIndex, int, int)), this, SLOT(updateItems()));
        connect(_sourceModel, SIGNAL(rowsRemoved(QModelIndex, int, int)), this, SLOT(updateItems()));
    }

}

void FilterPropertyModel::clearItems()
{
    //qDebug() << "FilterPropertyModel.clearItems";

    if(!_items.isEmpty()) {

        beginRemoveRows(QModelIndex(), 0, _items.size() - 1);
        _items.clear();
        endRemoveRows();
    }
}

void FilterPropertyModel::updateItems()
{
    //qDebug() << "FilterPropertyModel.updateItems";

    clearItems();

    if(_sourceModel != nullptr)
    {
        int nbItems = _sourceModel->rowCount();

        if(nbItems > 0) {

            auto hashMap = _sourceModel->roleNames();
            int role = _propertyName.isEmpty() ? -1 : hashMap.key(_propertyName.toLocal8Bit());

            //hashMap.
            QVector<int> items;
            for(int i=0; i<nbItems; ++i) {

                auto modelIndex = _sourceModel->index(i, 0);
                if(role != -1) {

                    auto value = _sourceModel->data(modelIndex, role);

                    if(value.toInt() == _propertyValue.toInt()) {
                        items.append(i);
                    }
                } else {
                    items.append(i);
                }
            }

            //
            if(!items.isEmpty()) {
                beginInsertRows(QModelIndex(), 0, items.size() - 1);
                _items = items;
                endInsertRows();
            }
        }
    }
}
