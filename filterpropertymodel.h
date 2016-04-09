#ifndef FILTERPROPERTYMODEL_H
#define FILTERPROPERTYMODEL_H

#include <QAbstractListModel>

/**
 * @brief FilterPropertyModel
 */
class FilterPropertyModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)
    Q_PROPERTY(QString propertyName READ propertyName WRITE setPropertyName NOTIFY propertyNameChanged)
    Q_PROPERTY(QVariant propertyValue READ propertyValue WRITE setPropertyValue NOTIFY propertyValueChanged)

public:
    FilterPropertyModel(QObject *parent = nullptr);

    /**
     * @brief rowCount
     * @param parent
     * @return
     */
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @brief data
     * @param index
     * @param role
     * @return
     */
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /**
     * @brief setData
     * @param index
     * @param value
     * @param role
     * @return
     */
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    /**
     * @brief roleNames
     * @return
     */
    virtual QHash<int, QByteArray> roleNames() const override;

    //
    QAbstractItemModel* sourceModel() const
    {
        return _sourceModel;
    }

    void setSourceModel(QAbstractItemModel* value);

    QString propertyName() const
    {
        return _propertyName;
    }

    void setPropertyName(const QString& value)
    {
        if(_propertyName != value)
        {
            _propertyName = value;
            updateItems();
        }
    }

    QVariant propertyValue() const
    {
        return _propertyValue;
    }

    void setPropertyValue(const QVariant& value)
    {
        if(_propertyValue != value)
        {
            _propertyValue = value;
            updateItems();
        }
    }

signals:
    void sourceModelChanged(QAbstractItemModel* value);
    void propertyNameChanged(const QString& value);
    void propertyValueChanged(const QVariant& value);

private slots:
    void clearItems();
    void updateItems();

private:
    QAbstractItemModel* _sourceModel;
    QString _propertyName;
    QVariant _propertyValue;

    QVector<int> _items;
};

#endif // FILTERPROPERTYMODEL_H
