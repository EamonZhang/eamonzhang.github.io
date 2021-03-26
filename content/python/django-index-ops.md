---
title: "django 默认创建第二索引"
date: 2020-04-16T11:40:02+08:00
draft: false
---

##### Django使用postgresql做数据库 db_index创建索引时会创建第二个索引varchar_pattern_ops问题

##### 创建默认索引
```
minion_id = models.CharField(max_length=100, db_index=True, blank=True, null=False, default="")
```

当字段类型是 models.CharField 或者 models.TextField 时 使用 db_index=True创建索引 会创建第二索引


django.db.backends.postgresql.schema

```
class DatabaseSchemaEditor(BaseDatabaseSchemaEditor):

    sql_alter_column_type = "ALTER COLUMN %(column)s TYPE %(type)s USING %(column)s::%(type)s"

    sql_create_sequence = "CREATE SEQUENCE %(sequence)s"
    sql_delete_sequence = "DROP SEQUENCE IF EXISTS %(sequence)s CASCADE"
    sql_set_sequence_max = "SELECT setval('%(sequence)s', MAX(%(column)s)) FROM %(table)s"

    sql_create_varchar_index = "CREATE INDEX %(name)s ON %(table)s (%(columns)s varchar_pattern_ops)%(extra)s"
    sql_create_text_index = "CREATE INDEX %(name)s ON %(table)s (%(columns)s text_pattern_ops)%(extra)s"

    def quote_value(self, value):
        return psycopg2.extensions.adapt(value)

    def _model_indexes_sql(self, model):
        output = super(DatabaseSchemaEditor, self)._model_indexes_sql(model)
        if not model._meta.managed or model._meta.proxy or model._meta.swapped:
            return output
//   创建第二索引
        for field in model._meta.local_fields:
            like_index_statement = self._create_like_index_sql(model, field)
            if like_index_statement is not None:
                output.append(like_index_statement)
        return output

    def _create_like_index_sql(self, model, field):
        """
        Return the statement to create an index with varchar operator pattern
        when the column type is 'varchar' or 'text', otherwise return None.
        """
        db_type = field.db_type(connection=self.connection)
        if db_type is not None and (field.db_index or field.unique):
            # Fields with database column types of `varchar` and `text` need
            # a second index that specifies their operator class, which is
            # needed when performing correct LIKE queries outside the
            # C locale. See #12234.
            #
            # The same doesn't apply to array fields such as varchar[size]
            # and text[size], so skip them.
            if '[' in db_type:
                return None
            if db_type.startswith('varchar'):
                return self._create_index_sql(model, [field], suffix='_like', sql=self.sql_create_varchar_index)
            elif db_type.startswith('text'):
                return self._create_index_sql(model, [field], suffix='_like', sql=self.sql_create_text_index)
        return None

```

##### 自定义索引

若不需要创建运算符类text_pattern_ops，varchar_pattern_ops 索引，改用：索引的基类 django.db.models.indexes.Index（fields，name）通过模型的Meta类中的索引选项使用它们


```
from django.db import models

class Person(models.Model):
    name = models.CharField(max_length=200)

    class Meta:
        indexes = [
            models.Index(
                fields=['name'],
                name='name_idx',
            ),
        ]
```

##### 组合索引

```
from django.db import models

class Person(models.Model):
    name = models.CharField(max_length=200)
    age = models.PositiveSmallIntegerField()

    class Meta:
        indexes = [
            models.Index(
                fields=['name', 'age'],
                name='name_age_idx',
            ),
        ]
```

##### 其他类型索引

非btree类型索引的创建

```
from django.contrib.postgres.fields import JSONField
from django.contrib.postgres.indexes import GinIndex
from django.db import models

class Doc(models.Model):
    data = JSONField()

    class Meta:
        indexes = [
            GinIndex(
                fields=['data'],
                name='data_gin',
            ),
        ]
```
