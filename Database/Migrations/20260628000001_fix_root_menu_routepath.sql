-- Fix root menu RoutePath: the 'system' root menu is a category node and
-- must NOT have a route path. Historical seed data wrote '/system' (URL style),
-- which caused MdiRouter.CanRoute('/system') to fail with "cannot route" on click.
-- Correct value is empty string, consistent with other category nodes.
-- See MainFrame.trmMenuSelectionChange: RoutePath='' means category node.

UPDATE UniAdmin_Menus SET RoutePath = '' WHERE MenuCode = 'system' AND RoutePath = '/system';
