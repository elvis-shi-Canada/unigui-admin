-- 示例增量迁移：给用户表加备注字段
-- 文件名约定：YYYYMMDDHHMMSS_描述.sql，按文件名(版本号)顺序应用
-- SchemaMigrations 表自动记录已应用版本，重复启动不会重跑
-- 此脚本为示例，演示机制；实际按需添加真实 Schema 变更

-- UP migration（正向）
ALTER TABLE UniAdmin_Users ADD COLUMN Remark TEXT;
